# frozen_string_literal: true

require 'bio'
require 'English'
require 'fileutils'

require 'npsearch_novel/arg_validator'
require 'npsearch_novel/logger'
require 'npsearch_novel/output'
require 'npsearch_novel/pool'
require 'npsearch_novel/scoresequence'
require 'npsearch_novel/sequence'
require 'npsearch_novel/signalp'
require 'npsearch/version'

# Top level module / namespace.
module NpSearch
  class <<self
    attr_accessor :opt, :config
    attr_accessor :sequences
    attr_reader :sorted_sequences

    def init(opt)
      @opt = opt
      ArgumentsValidators.run(opt)
      @sequences        = []
      @sorted_sequences = nil
      @mutex_json       = Mutex.new
      @pool             = initialise_thread_pool
      @config           = init_config(@opt[:input_file])
    end

    def run
      analysis_file = extract_orf(@opt[:input_file])
      iterate_input_file(analysis_file)
      @sorted_sequences = @sequences.sort_by(&:score).reverse
      produce_output
    end

    def logger
      @logger ||= Logger.new(STDOUT, @opt[:debug])
    end

    private

    def initialise_thread_pool
      return if @opt[:num_threads] == 1

      logger.debug "Creating a thread pool of size #{@opt[:num_threads]}"
      Pool.new(@opt[:num_threads])
    end

    def init_config(input_file)
      fname = File.basename(input_file, File.extname(input_file))
      out_dir = setup_output_dir(fname)
      {
        input_file: @opt[:input_file],
        type: @opt[:type],
        output_dir: out_dir,
        temp_dir: File.join(out_dir, 'tmp'),
        orf_file: File.join(out_dir, "tmp/#{fname}_orf.fa"),
        fasta_output: File.join(out_dir, "#{fname}_result.fa"),
        html_output: File.join(out_dir, "#{fname}_result.html"),
        json_output: File.join(out_dir, "#{fname}_result.json")
      }
    end

    ##
    # Creates the output folder
    def setup_output_dir(fname)
      dir_name = "#{fname}_" + Time.now.strftime('%Y_%m_%d_%H_%M_%S')
      default_outdir = File.join(Dir.pwd, dir_name)
      output_dir = @opt[:output_dir].nil? ? default_outdir : @opt[:output_dir]
      Dir.mkdir(output_dir)
      Dir.mkdir(File.join(output_dir, 'tmp'))
      output_dir
    end

    # Uses OrfM to extract all ORF (including nested ORFs)
    def extract_orf(input_file)
      return input_file if @opt[:type] == :protein

      logger.debug 'Attempting to extract ORFs.'
      cmd = "orfm #{input_file} > #{@config[:orf_file]}"
      logger.debug "Running: #{cmd}"
      system(cmd)
      logger.debug("orfm Exit Code: #{$CHILD_STATUS.exitstatus}")
      @config[:orf_file]
    end

    def extract_orf_cmd(input, minsize)
      cmd = "#{@opt[:getorf_path]} -minsize #{minsize} -sequence #{input}" \
            " -outseq #{@config[:orf_file]}"
      cmd += ' >/dev/null 2>&1' unless @opt[:debug]
      logger.debug "Running: #{cmd}"
      cmd
    end

    def iterate_input_file(input_file)
      i = 0
      Bio::FlatFile.open(Bio::FastaFormat, input_file).each_entry do |entry|
        if @opt[:num_threads] > 1
          @pool.schedule(entry) { |e, idx| initialise_seqs(e, idx) }
        else
          initialise_seqs(entry, i)
        end
        i += 1
      end
    ensure
      @pool.shutdown if @opt[:num_threads] > 1
    end

    def initialise_seqs(entry, idx)
      logger.debug "-- Analysing: '[#{idx}]' '#{entry.entry_id}'"
      return unless ensure_seq_long_enough(entry, idx)

      sp = Signalp.analyse_sequence(entry.aaseq.to_s, idx)
      return if sp[:sp] != 'Y'

      seq = Sequence.new(entry, sp, idx)
      return unless ensure_no_illegal_characters(entry, seq, idx)

      ScoreSequence.run(seq, @opt)
      @sequences << seq
    end

    def ensure_seq_long_enough(entry, idx)
      return true unless entry.aaseq.length > @opt[:max_orf_length]

      logger.debug "-- Skipping: '[#{idx}]' '#{entry.entry_id}' - " \
                   " Too small (L:#{entry.aaseq.length})"
      false
    end

    def ensure_no_illegal_characters(entry, seq, idx)
      return true unless seq.seq =~ /[^A-Za-z]/

      logger.debug "-- Skipping: '[#{idx}]' '#{entry.entry_id}' - " \
                   ' Contains illegal characters.'
      false
    end

    def produce_output
      Output.to_fasta(@config[:fasta_output], @sorted_sequences, @config[:type])
      Output.to_html(@config[:html_output])
    end
  end
end
