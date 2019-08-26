# frozen_string_literal: true

require 'forwardable'
require 'securerandom'

# Top level module / namespace.
module NpHMMer
  # A class to hold sequence data
  class Signalp
    class << self
      extend Forwardable
      def_delegators NpHMMer, :opt

      def analyse_sequence(seq, hsp_indexes)
        data        = setup_analysis(seq, hsp_indexes)
        signalp_out = `#{opt[:signalp_path]} -fasta #{data[:fname]} \
                       -format short -stdout -org euk -tmp #{opt[:temp_dir]}`
        format_signalp_results(signalp_out, data)
      end

      private

      def setup_analysis(seq, hsp_indexes)
        if opt[:type] == :protein
          data = { seq: [seq.seq], fasta: ">seq\n#{seq.seq}" }
          data[:fname] = write_fasta_to_file(data)
          return data
        end

        hsp_start           = hsp_indexes[0][0]
        sequence_before_hsp = seq.seq[0, hsp_start].to_s
        if sequence_before_hsp.include?('M') && sequence_before_hsp.size > 15
          min_length = seq.seq.length - hsp_start - 15
          min_length = 1 if min_length.negative?
          orfs = seq.seq.scan(/(?=(M\w{#{min_length},}))./).flatten
          data = { seq: orfs, fasta: create_orf_fasta(orfs) }
        else
          data = { seq: [seq.seq], fasta: ">seq\n#{seq.seq}" }
        end
        data[:fname] = write_fasta_to_file(data)
        data
      end

      def create_orf_fasta(m_orf)
        fasta = ''
        m_orf.each_with_index { |seq, idx| fasta << ">#{idx}\n#{seq}\n" }
        fasta
      end

      def write_fasta_to_file(data)
        fname = 'npsearch-tmp-fasta-' + SecureRandom.uuid + '.fa'
        file = Pathname.new(opt[:temp_dir]) + fname
        File.open(file, 'w') { |f| f.puts data[:fasta] }
        file.to_s
      end

      def format_signalp_results(signalp_out, data)
        sp_headers = %w[orf id prediction sp_score other_score position]
        orf_results = []
        sp_results = signalp_out.split("\n").delete_if { |l| l[0] == '#' }
        sp_results.each_with_index do |line, idx|
          line = data[:seq][idx].to_s + "\t" + line
          results = Hash[sp_headers.map(&:to_sym).zip(line.split("\t"))]
          results[:sp] = results[:position].nil? ? 'N' : 'Y'
          match = results[:position]&.match(/CS pos: \d+-(\d+)/)
          results[:ymax_pos] = match[1] unless match.nil?
          orf_results << results
        end
        orf_results.sort_by { |h| h[:d] }.reverse[0]
      end
    end
  end
end
