require 'forwardable'
require 'neurohmmer'

module NeuroHmmerApp
  # Module that runs NeuroHmmer
  module RunNeuroHmmer
    # To signal error in query sequence or options.
    #
    # ArgumentError is raised when BLAST+'s exit status is 1; see [1].
    class ArgumentError < ArgumentError
    end

    # To signal internal errors.
    #
    # RuntimeError is raised when there is a problem in writing the input file,
    # in running BLAST, get_raw_sequence or genevalidator. These are rare,
    # infrastructure errors, used internally, and of concern only to the
    # admins/developers.
    class RuntimeError < RuntimeError
    end

    class << self
      extend Forwardable

      def_delegators NeuroHmmerApp, :config, :logger, :public_dir

      attr_reader :gv_dir, :input_file, :xml_file, :raw_seq, :unique_id, :params

      # Setting the scene
      def init(base_url, params)
        create_unique_id
        create_run_dir
        @params = params
        validate_params
        # @url = produce_result_url_link(base_url)
      end

      # Runs genevalidator & Returns parsed JSON, or link to JSON/results file
      def run
        write_seqs_to_file
        run_neurohmmer
      end

      private

      # Creates a unique run ID (based on time),
      def create_unique_id
        @unique_id = Time.new.strftime('%Y-%m-%d_%H-%M-%S_%L-%N')
        @run_dir   = File.join(NeuroHmmerApp.public_dir, 'NeuroHmmer',
                               @unique_id)
        ensure_unique_id
      end

      # Ensures that the Unique id is unique (if a sub dir is present in the
      #  temp dir with the unique id, it simply creates a new one)
      def ensure_unique_id
        while File.exist?(@run_dir)
          @unique_id = create_unique_id
          @run_dir   = File.join(NeuroHmmerApp.public_dir, 'NeuroHmmer',
                                 @unique_id)
        end
        logger.debug("Unique ID = #{@unique_id}")
      end

      # Create a sub_dir in the Tempdir (name is based on unique id)
      def create_run_dir
        logger.debug("NeuroHmmerApp Tempdir = #{@run_dir}")
        FileUtils.mkdir_p(@run_dir)
      end

      # Validates the paramaters provided via the app.
      #  Only important if POST request is sent via API - Web APP also validates
      #  all params via Javascript.
      def validate_params
        logger.debug("Input Paramaters: #{@params}")
        check_seq_param_present
        check_seq_length
        check_nps_param_present
      end

      # Simply asserts whether that the seq param is present
      def check_seq_param_present
        return if @params[:seq]
        fail ArgumentError, 'No input sequence provided.'
      end

      def check_seq_length
        return unless config[:max_characters] != 'undefined'
        return if @params[:seq].length < config[:max_characters]
        fail ArgumentError, 'The input sequence is too long.'
      end

      def check_nps_param_present
        return if @params[:neuropeptides]
        fail ArgumentError, 'No neuropeptides groups specified'
      end

      # Writes the input sequences to a file with the sub_dir in the temp_dir
      def write_seqs_to_file
        @input_file = File.join(@run_dir, 'input_file.fa')
        logger.debug("Writing input seqs to: '#{@input_file}'")
        ensure_unix_line_ending
        ensure_fasta_valid
        File.open(@input_file, 'w+') { |f| f.write(@params[:seq]) }
        assert_input_file_present
      end

      def ensure_unix_line_ending
        @params[:seq].gsub!(/\r\n?/, "\n")
      end

      # Adds a ID (based on the time when submitted) to sequences that are not
      #  in fasta format.
      def ensure_fasta_valid
        logger.debug('Adding an ID to sequences that are not in fasta format.')
        unique_queries = {}
        sequence       = @params[:seq].lstrip
        if sequence[0] != '>'
          sequence.insert(0, '>Submitted:'\
                             "#{Time.now.strftime('%H:%M-%B_%d_%Y')}\n")
        end
        sequence.gsub!(/^\>(\S+)/) do |s|
          if unique_queries.key?(s)
            unique_queries[s] += 1
            s + '_' + (unique_queries[s] - 1).to_s
          else
            unique_queries[s] = 1
            s
          end
        end
        @params[:seq] = sequence
      end

      # Asserts that the input file has been generated and is not empty
      def assert_input_file_present
        return if File.exist?(@input_file) && !File.zero?(@input_file)
        fail 'NeuroHmmerApp was unable to create the input file.'
      end

      def run_neurohmmer
        opt = {
          temp_dir: File.join(@run_dir, 'tmp'),
          input_file: @input_file,
          num_threads: config[:num_threads],
          signalp_path: config[:signalp_path]
        }
        Neurohmmer.init(opt)
        Neurohmmer::Hmmer.search
        hmm_results = Neurohmmer::Hmmer.analyse_output
        Neurohmmer::Output.format_seqs_for_html(hmm_results)
      end

      def create_log_file
        @log_file = File.join(@run_dir, 'log_file.txt')
        logger.debug("Log file: #{@log_file}")
      end
    end
  end
end 
