# frozen_string_literal: true

require 'forwardable'

require 'npsearch_hmm/signalp'

# Top level module / namespace.
module NpHMMer
  # A Helper class that is run from with the slim template
  class HighlightSequence
    class <<self
      extend Forwardable
      def_delegators NpHMMer, :opt, :conf

      def format_evalue(evalue)
        return '' if evalue.nil?
        return evalue unless evalue.include?('e')

        formated_evalue = evalue.split('e')
        formated_evalue[0] + '&nbsp;&times;&nbsp;10<sup>' + formated_evalue[1] +
          '</sup>'
      end

      def format_seqs(seq, hmmer_results)
        hmmer_results = update_hmmer_results(hmmer_results, seq)
        hsp_indexes = calculate_hsp_start(hmmer_results)
        seq.signalp = calculate_signalp(seq, hsp_indexes)
        seq.orf     = extract_orf(seq)
        formatting  = calculate_formatting_classes(hmmer_results, seq)
        annotate_seq(String.new(seq.orf), formatting)
      end

      def format_translated_seqs(translated_seq, formated_seq)
        clean_seq  = formated_seq.gsub(/<.+?>/, '').chomp
        translated = translated_seq.split(clean_seq)
        seq = ''
        seq << annotate_motifs(translated[0]) unless translated[0].nil?
        seq << formated_seq.chomp
        seq << annotate_motifs(translated[1]) unless translated[1].nil?
        seq
      end

      def format_domain_alignments(domains)
        dom_sections = zip_alignments(domains)
        dom_sections = format_dom_sections(dom_sections,
                                           domains[:data][:ali_from].to_i,
                                           domains[:data][:hmm_from].to_i)
        dom_sections
      end

      private

      def update_hmmer_results(hmmer_results, seq)
        hmmer_results[:domains] = hmmer_results[:domains].map do |domain|
          complete_target = 'No individual domains that satisfy reporting' \
                            ' thresholds (although complete target did)'
          if domain != complete_target
            domain
          else
            {
              data: { ali_from: 0, ali_to: seq.orf.length },
              desc: complete_target
            }
          end
        end
        hmmer_results
      end

      def extract_orf(seq)
        if seq.signalp.nil? || seq.signalp[:sp] == 'N'
          seq.orf_index = 0
          return seq.seq
        end
        seq.orf_index = seq.seq.index(seq.signalp[:orf])
        seq.signalp[:orf]
      end

      # calculate the start idx of the HSP, so can look for Signal peptide
      # before Signal Peptide
      def calculate_hsp_start(hmmer_results)
        hsp_indexes = hmmer_results[:domains].map do |domain|
          next unless domain.is_a? Hash

          [domain[:data][:ali_from]&.to_i, domain[:data][:ali_to]&.to_i]
        end
        hsp_indexes.sort_by(&:min)
      end

      def calculate_signalp(seq, hsp_indexes)
        return nil if opt[:signalp_path].nil?
        return seq.signalp unless seq.signalp.nil?

        Signalp.analyse_sequence(seq, hsp_indexes)
      end

      def calculate_formatting_classes(hmmer_results, seq)
        hsps = hmmer_results[:domains].map do |d|
          next if d.is_a? String

          Range.new(d[:data][:ali_from].to_i - seq.orf_index,
                    d[:data][:ali_to].to_i - seq.orf_index)
        end
        hsps = merge_ranges(hsps)
        pos = check_sp_hsp_overlap(hsps, seq.signalp)
        convert_to_hash(pos[0], pos[1], pos[2])
      end

      def merge_ranges(ranges)
        ranges.size.times do
          ranges = ranges.sort_by(&:begin)
          t = ranges.each_cons(2).to_a
          t.each do |r1, r2|
            next unless (r2.cover? r1.begin) || (r2.cover? r1.end) ||
                        (r1.cover? r2.begin) || (r1.cover? r2.end)

            ranges << Range.new([r1.begin, r2.begin].min, [r1.end, r2.end].max)
            ranges.delete_at(ranges.index(r1) || ranges.length)
            ranges.delete_at(ranges.index(r2) || ranges.length)
            t.delete [r1, r2]
          end
        end
        ranges
      end

      def check_sp_hsp_overlap(hsps, signalp)
        return [hsps, nil, nil] if signalp.nil? || signalp[:sp] == 'N'

        signalp_range = Range.new(1, signalp[:ymax_pos].to_i - 1)
        sp = []
        hsps.each do |hsp|
          next unless signalp_range.cover?(hsp.min)

          sp << Range.new(signalp_range.min, hsp.min - 1)
          sp << Range.new(hsp.min, signalp_range.max)
          hsps.delete(hsp)
          next if hsp.max <= signalp_range.max + 1

          hsps << Range.new(signalp_range.max + 1, hsp.max)
        end
        hsps.sort_by!(&:min)
        sp << signalp_range if sp.empty?
        [hsps, sp[0], sp[1]]
      end

      def convert_to_hash(hsps, sp, sphsp)
        results = []
        results += range_to_hash([sp], 'sp') unless sp.nil?
        results += range_to_hash([sphsp], 'sphsp') unless sphsp.nil?
        results += range_to_hash(hsps, 'hsp')
        results.sort_by { |s| s[:pos] }
      end

      def range_to_hash(range, cl)
        return nil if range.nil?

        hashes = []
        range.each do |r|
          next if r.min.to_i - 1 < 0 || r.max.to_i - 0.1 < 0

          hashes << { pos: r.min.to_i - 1, insert: "<span class=#{cl}>" }
          hashes << { pos: r.max.to_i - 0.1, insert: '</span>' } # for ordering
        end
        hashes
      end

      def annotate_seq(seq, formatting)
        formatting.each do |f|
          seq = insert_annotation(seq, f[:insert], f[:pos].ceil)
        end
        annotate_motifs(seq)
      end

      def insert_annotation(seq, insert, pos)
        ofst = seq.scan(/<.*?>/).join.length
        seq.insert(pos + ofst, insert)
      end

      def annotate_motifs(seq)
        seq.gsub(/KR|KK|RR/i, '<span class=clv>\0</span>')
           .gsub(/(K|R)<span class=hsp>(K|R)/i, '<span class=clv>\1</span>' \
                 '<span class=clv_i>\2</span><span class=hsp>')
           .gsub('<span class=clv>R</span><span class=clv_i>K</span><span' \
                 ' class=hsp>', 'R<span class=hsp>K')
           .gsub(%r{G</span><span class=clv>},
                 '<span class=gly>G</span></span><span class=clv>')
           .gsub(/G<span class=clv>/,
                 '<span class=gly>G</span><span class=clv>')
      end

      def zip_alignments(domain)
        hmms = domain[:alignment][:hmm].scan(/.{1,60}/)
        aligned = domain[:alignment][:aligned].scan(/.{1,60}/)
        query = domain[:alignment][:query].scan(/.{1,60}/)
        score = domain[:alignment][:score].scan(/.{1,60}/)
        query.zip(aligned, hmms, score)
      end

      def format_dom_sections(dom_sections, ali, hmm)
        dom_sections.each do |row|
          n = calculate_domain_row_numbers(row, ali, hmm)
          row[0].insert(0, n[:q_start]).insert(-1, n[:q_end])
          row[1].insert(0, ' ' * n[:q_start].length)
                .insert(-1, '' * n[:q_end].length)
          row[2].insert(0, n[:m_start]).insert(-1, n[:m_end])
          row[3].insert(0, ' ' * n[:q_start].length)
                .insert(-1, '' * n[:q_end].length)
          ali = n[:ali]
          hmm = n[:hmm]
        end
        dom_sections
      end

      def calculate_domain_row_numbers(row, ali, hmm)
        query = "Query: #{ali.to_s.rjust(3)} "
        model = "Model: #{hmm.to_s.rjust(3)} "
        ali += row[0].gsub(/[\.\-]/, '').length
        hmm += row[2].gsub(/[\.\-]/, '').length
        query_end = " #{(ali - 1).to_s.ljust(3)}"
        model_end = " #{(hmm - 1).to_s.ljust(3)}"
        { q_start: query, q_end: query_end, m_start: model, m_end: model_end,
          ali: ali, hmm: hmm }
      end
    end
  end
end
