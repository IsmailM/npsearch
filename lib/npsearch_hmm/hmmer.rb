require 'csv'
require 'forwardable'

require 'npsearch_hmm/hit'

# Top level module / namespace.
module NpHMMer
  # A class that holds methods related to HMMer
  class Hmmer
    class << self
      extend Forwardable
      def_delegators NpHMMer, :opt

      # Run hmmsearch for each hmm model in conf[:hmm_dir] with the input file
      # Results are aggregated in conf[:hmm_output]
      def search
        hmm_dir = File.expand_path('../../data/hmm', __dir__)
        hmm_dir = opt[:hmm_models_dir] unless opt[:hmm_models_dir].nil?
        Dir.foreach(hmm_dir) do |h|
          hmm_file = File.join(hmm_dir, h)
          next if hmm_file !~ /hmm$/
          hmm_search(hmm_file)
        end
      end

      # Analyses the hmmsearch aggregated output (i.e. in conf[:hmm_output])
      def analyse_output
        hmm_output_file = File.join(opt[:temp_dir], 'nphmmer.hmm_search.out')
        hits = []
        hmmer_output = NpHMMer::Hmmer::Parse.analyse(hmm_output_file)
        hmmer_output.each { |id, hit| hits << Hit.new(id, hit) }
        hits
      end

      private

      def hmm_search(hmm_file)
        hmm_output = File.join(opt[:temp_dir], 'nphmmer.hmm_search.out')
        input_file = opt[:type] == :genetic ? opt[:orf] : opt[:input]
        `hmmsearch --notextw --cpu #{opt[:num_threads]} #{opt[:deep_analysis]} \
          -E #{opt[:evalue]} '#{hmm_file}' '#{input_file}' >> '#{hmm_output}'`
      end
    end

    # A class that generate HMM models for fasta file in a directory.
    class Generate
      class << self
        def hmm_models(opt)
          Dir.foreach(opt[:generate_hmms]) do |file|
            next if file !~ /fa(sta)?$/
            np_fasta_file  = File.join(opt[:generate_hmms], file)
            aligned_file   = File.join(opt[:generate_hmms], '../alignments',
                                       "#{file.gsub(/fa(sta)?$/, '')}aligned")
            hmm_model_file = File.join(opt[:generate_hmms], '../hmm',
                                       "#{file.gsub(/fa(sta)?$/, '')}hmm")
            mafft(np_fasta_file, aligned_file, opt[:num_threads])
            hmm_build(aligned_file, hmm_model_file, opt[:num_threads])
          end
        end

        private

        def mafft(input, aligned_file, num_threads)
          `mafft --maxiterate 1000 --quiet --thread #{num_threads} --quiet  \
          '#{input}' > '#{aligned_file}'`
        end

        def hmm_build(aligned_file, hmm_model_file, num_threads)
          `hmmbuild --cpu #{num_threads} '#{hmm_model_file}' '#{aligned_file}'`
        end
      end
    end

    # A class that parses the HMM output
    class Parse
      class << self
        def analyse(hmm_file)
          results = {}
          data = clean_hmm_output_file(hmm_file)
          data.each do |hits|
            model = parse_model(hits)
            scores = parse_scores_section(hits)
            domains = parse_domain_section(hits)
            scores.zip(domains).each do |hit|
              hit_data = parse_into_hash(hit, model)
              results[hit_data[:query_id]] ||= []
              results[hit_data[:query_id]] << hit_data
            end
          end
          results
        end

        private

        # Remove all comments & No Hit Sections and split the results based on
        # each HMM result.
        def clean_hmm_output_file(hmm_file)
          content = File.read(hmm_file)
          content.gsub!(/\n\n\n?\n?/, "\n")
          content.gsub!(/#.*\n/, '')
          content.gsub!(/^Internal(.*\n){10}/, '')
          # remove no hits sections
          content.gsub!(%r{(.*\n){6}\s+\[No.targets.detected.*?\]\n//\n\[ok\]\n}x, '')
          content.gsub!(/\s+---.*/, '')
          content = content.lines[0..-3].join # remove last divider'
          content.split(%r{\n//\n\[ok\]\n})
        end

        def parse_model(hit)
          hit.lines[0].match(/Query:\s+(.*)/)[1].gsub(/  \[.*?\]$/, '')
        end

        def parse_scores_section(hits)
          s = hits.match(/Scores for complete sequences \(score includes all domains\):\n(.*?)Domain annotation/m)[1]
          s.lines
        end

        def parse_domain_section(hits)
          d = hits.match(/Domain annotation for each sequence \(and alignments\):\n(.*)/m)[1]
          d.split(/^>> /)[1..-1]
        end

        def parse_into_hash(hit, model)
          { model: model,
            overall_results: parse_overall_results(hit[0]),
            query_id: parse_id(hit[1]),
            query_name: parse_query(hit[1]),
            domains: parse_domains_data(hit[1], model) }
        end

        def parse_query(hit)
          hit.lines[0].chomp
        end

        def parse_id(hit)
          hit.lines[0].match(/^(\S+)/)[1]
        end

        def parse_overall_results(overall_result)
          overall_result.gsub!(/^\s+/, '')
          headers = %w(full_seq_e_value full_seq_score full_seq_bias
                       best_dom_e_value best_dom_score best_dom_bias dom_exp
                       dom_N)
          Hash[headers.map(&:to_sym).zip(overall_result.split(/\s+/)[0..7])]
        end

        def parse_domains_data(domain_section, model)
          domains_section = domain_section.lines[1..-1].join # remove id line
          domain_data = []
          domains     = parse_domains_section(domains_section)
          if domains.nil?
            domain_data << 'No individual domains that satisfy reporting' \
                           ' thresholds (although complete target did)'
          else
            alignments = parse_alignments_section(domain_section, domains)
            domains.each_with_index do |domain, idx|
              domain_data << { data: parse_domain_csv(domain),
                               alignment: parse_alignment(alignments[idx],
                                                          model) }
            end
          end
          domain_data
        end

        def parse_domains_section(domain_section)
          doms = domain_section.match(/(.*)\n\s+Alignments/m)
          doms.nil? ? doms : doms[1].lines
        end

        def parse_alignments_section(domain_section, domains)
          a = domain_section.lines[domains.length + 2..-1]
                            .join.split(/  == domain.*\n/)
          a[1..-1]
        end

        def parse_domain_csv(domain)
          domain = clean_domain_csv(domain)
          headers = %w(domain_no score bias c_e_value i_e_value hmm_from hmm_to
                       ali_from ali_to env_from env_to acc)
          Hash[headers.map(&:to_sym).zip(domain.split(/\s+/))]
        end

        def clean_domain_csv(domain)
          domain.gsub!(/^\s+/, '')
          domain.gsub!(/[!\?\[\]]/, '')
          domain.gsub!(/\.\./, '')
          domain.gsub!(/ \./, '')
          domain
        end

        def parse_alignment(alignment, model)
          lines  = alignment.lines
          offset = lines[0].match(/(\s+#{model}\s+\d+\s+)/)[1].length
          lines.each { |l| l.gsub!(/^.{#{offset}}/, '').chomp! }
          {
            hmm: lines[0].gsub(/ \d+\s*$/, ''),
            aligned: lines[1],
            query: lines[2].gsub(/ \d+\s*$/, ''),
            score: lines[3].gsub(/ PP\s*$/, '')
          }
        end
      end
    end
  end
end