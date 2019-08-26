# frozen_string_literal: true

require 'bio'
require 'bigdecimal'
require 'fileutils'

require 'npsearch_hmm/arg_validators'
require 'npsearch_hmm/hmmer'
require 'npsearch_hmm/output'

# Top level module / namespace.
module NpHMMer
  class <<self
    attr_accessor :opt
    attr_reader :results

    def init(opt)
      FileUtils.mkdir_p(opt[:temp_dir])
      @opt = ArgumentsValidators.run(opt)
      extract_orf if @opt[:type] == :genetic
    end

    def run
      Hmmer.search
      @results = Hmmer.analyse_output
      # order results by E-values
      @results.sort_by! { |seq| BigDecimal(seq.lowest_evalue) }
      output_dir = Output.create_output_dir
      Output.to_fasta(@results, output_dir)
      Output.to_html(output_dir)
      remove_temp_dir
    end

    private

    # Uses getorf from EMBOSS package to extract all ORF
    def extract_orf(input = @opt[:input], minsize = 90)
      @opt[:orf] = File.join(@opt[:temp_dir], 'nphmmer.orf.fa')
      system "getorf -sequence #{input} -outseq #{@opt[:orf]}" \
             " -minsize #{minsize} >/dev/null 2>&1"
    end

    def remove_temp_dir
      return unless File.directory?(@opt[:temp_dir])

      FileUtils.rm_rf(@opt[:temp_dir])
    end
  end
end
