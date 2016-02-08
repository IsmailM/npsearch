require 'bigdecimal'
require 'forwardable'
require 'nphmmer'

module NpHMMerApp
  # Module that runs NpHmmer
  module RunNpHMMer
    # To signal error in query sequence or options.
    #
    # ArgumentError is raised when there is an issue with the program.
    class ArgumentError < ArgumentError
    end

    # To signal internal errors.
    #
    # RuntimeError is raised when there is a problem in writing the input file,
    # in running NpHMMer. These are rare, infrastructure errors, used
    # internally, and of concern only to the admins/developers.
    class RuntimeError < RuntimeError
    end

    class << self
      extend Forwardable

      def_delegators NpHMMerApp, :config, :logger, :public_dir

      attr_reader :gv_dir, :input_file, :xml_file, :raw_seq, :unique_id, :params

      # Setting the scene
      def init(_base_url, params)
        create_unique_id_and_run_dir
        @params = params
        validate_params
        # @url = produce_result_url_link(base_url)
      end

      # Writes sequesnces to file and runs NpHMMer
      def run
        write_seqs_to_file
        run_nphmmer
      end

      private

      # Creates a unique run ID (based on time) and a the run directory
      def create_unique_id_and_run_dir
        @unique_id = Time.new.strftime('%Y-%m-%d_%H-%M-%S_%L-%N')
        @run_dir   = File.join(NpHMMerApp.public_dir, 'NpHmmer', @unique_id)
        ensure_unique_id
        create_run_dir
      end

      # Ensures that the Unique id is unique (if a sub dir is present in the
      #  temp dir with the unique id, it simply creates a new one)
      def ensure_unique_id
        while File.exist?(@run_dir)
          @unique_id = create_unique_id
          @run_dir   = File.join(NpHMMerApp.public_dir, 'NpHMMer',  @unique_id)
        end
        logger.debug("Job Unique ID = #{@unique_id}")
      end

      # Create a sub_dir in the Tempdir (name is based on unique id)
      def create_run_dir
        logger.debug("NpHMMerApp Tempdir = #{@run_dir}")
        FileUtils.mkdir_p(@run_dir)
      end

      # # Reuturns the URL of the results page.
      # def produce_result_url_link(url)
      #   url.gsub(/input/, '').gsub(%r{/*$}, '') +
      #     "/NpHmmer/#{@unique_id}/output.html"
      # end

      # Validates the paramaters provided via the app.
      #  Only important if POST request is sent via API - Web APP also validates
      #  all params via Javascript.
      def validate_params
        logger.debug("Input Paramaters: #{@params}")
        check_seq_param_present
        check_seq
        check_seq_length
      end

      # Simply asserts whether that the seq param is present
      def check_seq_param_present
        return if @params[:seq]
        fail ArgumentError, 'No input sequence provided.'
      end

      def check_seq
        logger.debug('Cleaning input sequences')
        ensure_unix_line_ending
        remove_bad_char_in_seq
        ensure_fasta_valid
        ensure_unique_queries
      end

      def ensure_unix_line_ending
        @params[:seq].gsub!(/\r\n?/, "\n")
      end

      def remove_bad_char_in_seq
        cleaned_seqs = ''
        @params[:seq].each_line do |line|
          if line =~ /^>/
            cleaned_seqs << line
            next
          end
          cleaned_seqs << line.gsub(/\W+/, '') + "\n"
        end
        @params[:seq] = cleaned_seqs
      end

      # Adds a ID (based on the time when submitted) to sequences that are not
      #  in fasta format.
      def ensure_fasta_valid
        logger.debug('Adding an ID to sequences that are not in fasta format.')
        sequence       = @params[:seq].lstrip
        if sequence[0] != '>'
          inserted_id = ">Submitted: #{Time.now.strftime('%H:%M-%B_%d_%Y')}\n"
          sequence.insert(0, inserted_id)
        end
        @params[:seq] = sequence
      end

      def ensure_unique_queries
        unique_queries = {}
        @params[:seq].gsub!(/^\>(\S+)/) do |s|
          if unique_queries.key?(s)
            unique_queries[s] += 1
            s + '_' + (unique_queries[s] - 1).to_s
          else
            unique_queries[s] = 1
            s
          end
        end
      end

      def check_seq_length
        return unless config[:max_characters] != 'undefined'
        return if @params[:seq].length < config[:max_characters]
        fail ArgumentError, 'The input sequence is too long.'
      end

      # Writes the input sequences to a file with the sub_dir in the temp_dir
      def write_seqs_to_file
        @input_file = File.join(@run_dir, 'input_file.fa')
        logger.debug("Writing input seqs to: '#{@input_file}'")
        File.open(@input_file, 'w+') { |f| f.write(@params[:seq]) }
        return if File.exist?(@input_file) && !File.zero?(@input_file)
        fail 'NpHMMerApp was unable to create the input file.'
      end

      def run_nphmmer
        opt = init_nphmmer_arguments
        NpHMMer.init(opt)
        NpHMMer::Hmmer.search
        results = NpHMMer::Hmmer.analyse_output
        results.sort_by { |seq| BigDecimal.new(seq.lowest_evalue) }
      end

      def init_nphmmer_arguments
        opt = {
          temp_dir: File.join(@run_dir, 'tmp'),
          input: @input_file,
          num_threads: config[:num_threads],
          evalue: @params[:evalue]
        }
        opt[:signalp_path] = config[:signalp_path] if @params[:signalp] == 'on'
        logger.debug("NpHMMer OPTS: #{opt}")
        opt
      end

      def create_log_file
        @log_file = File.join(@run_dir, 'log_file.txt')
        logger.debug("Log file: #{@log_file}")
      end
    end
  end
end
