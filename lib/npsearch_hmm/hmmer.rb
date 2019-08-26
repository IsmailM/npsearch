# frozen_string_literal: true

require 'csv'
require 'forwardable'
require 'fileutils'
require 'pathname'

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
        hmm_dir = [Pathname.new('../../data/hmm').expand_path(__dir__)]
        hmm_dir = opt[:hmm_models_dir] unless opt[:hmm_models_dir].nil?
        hmm_dir.each do |dir|
          Dir.foreach(dir) do |h|
            next unless h.end_with? 'hmm'
            next if in_filter_list(h)

            hmm_file = File.join(dir, h)
            hmm_search(hmm_file)
          end
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

      def in_filter_list(hmm_file)
        return false if opt[:filter_hmm_list].nil?

        fname = File.basename(hmm_file, '.hmm')
        return false if opt[:filter_hmm_list].include? fname

        true
      end

      def hmm_search(hmm_file)
        output = File.join(opt[:temp_dir], 'nphmmer.hmm_search.out')
        input_file = opt[:type] == :genetic ? opt[:orf] : opt[:input]
        deep = opt[:deep_analysis].nil? ? '' : '--max --nonull2'
        cmd = "hmmsearch --notextw --cpu #{opt[:num_threads]} #{deep}" \
              " -E #{opt[:evalue]} '#{hmm_file}' '#{input_file}' >> '#{output}'"
        system(cmd)
      end
    end

    # A class that generate HMM models for fasta file in a directory.
    class Generate
      class << self
        def hmm_models(opt)
          set_up_dirs(opt[:input_dir])
          all_files_in_dir(opt[:input_dir]).each do |file|
            f_base = file.basename(file.extname)
            if opt[:aligned]
              generate_hmm_profiles(file, f_base, opt[:num_threads])
            else
              align_and_generate_hmm_profiles(file, f_base, opt[:num_threads])
            end
          end
        end

        def set_up_dirs(dir)
          d = Pathname.new(dir).dirname
          @aligned_dir = d + 'alignments'
          @hmm_model_dir = d + 'hmm'
          FileUtils.mkdir(@aligned_dir) unless @aligned_dir.exist?
          FileUtils.mkdir(@hmm_model_dir) unless @hmm_model_dir.exist?
        end

        # assumes that set_up_dirs has been run first
        def align_and_generate_hmm_profiles(input, f_basename, num_threads)
          aligned_file = @aligned_dir + "#{f_basename}.aln"
          hmm_model_file = @hmm_model_dir + "#{f_basename}.hmm"
          run_mafft(input, aligned_file, num_threads)
          run_hmm_build(aligned_file, hmm_model_file, num_threads)
        end

        # assumes that set_up_dirs has been run first
        def generate_hmm_profiles(input, f_basename, num_threads)
          hmm_model_file = @hmm_model_dir + "#{f_basename}.hmm"
          FileUtils.mkdir(hmm_model_dir) unless hmm_model_dir.exist?
          run_hmm_build(input, hmm_model_file, num_threads)
        end

        def run_mafft(input, aligned_file, num_threads)
          system('mafft --maxiterate 1000 --genafpair --quiet ' \
                 " --thread #{num_threads} '#{input}' > '#{aligned_file}'")
        end

        def run_hmm_build(aligned_file, hmm_model_file, num_threads)
          system("hmmbuild --cpu #{num_threads} '#{hmm_model_file}' " \
                 "'#{aligned_file}'")
        end

        def all_files_in_dir(dir)
          files = []
          Pathname.new(dir).each_child do |file|
            next if file.basename.to_s.start_with? '.'

            files << all_files_in_dir(file) if file.directory?
            files << file
          end
          files.flatten
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
          headers = %w[full_seq_e_value full_seq_score full_seq_bias
                       best_dom_e_value best_dom_score best_dom_bias dom_exp
                       dom_N]
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
          headers = %w[domain_no score bias c_e_value i_e_value hmm_from hmm_to
                       ali_from ali_to env_from env_to acc]
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
