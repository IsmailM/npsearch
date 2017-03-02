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

      attr_reader :unique_id, :params

      # Setting the scene
      def init(_base_url, params)
        create_unique_id_and_run_dir
        @params = params
        @params[:input_file] = File.join(@run_dir, 'input_file.fa')
        logger.debug("Input Paramaters: #{@params}")
        validate_params if params[:file_uuid].empty?
      end

      # Writes sequesnces to file and runs NpHMMer
      def run
        if params[:file_uuid].empty?
          write_seqs_to_file
        else
          copy_uploaded_file
        end
        run_nphmmer
      end

      private

      # Creates a unique run ID (based on time) and a the run directory
      def create_unique_id_and_run_dir
        @unique_id = Time.new.strftime('%Y-%m-%d_%H-%M-%S_%L-%N')
        @run_dir   = File.join(NpHMMerApp.public_dir, 'NpHMMer', @unique_id)
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

      # Validates the paramaters provided via the app.
      #  Only important if POST request is sent via API - Web APP also validates
      #  all params via Javascript.
      def validate_params
        assert_seq_param_present
        ensure_fasta_valid
        check_seq_length
      end

      # Simply asserts whether that the seq param is present
      def assert_seq_param_present
        return if @params[:seq]
        fail ArgumentError, 'No input sequence provided.'
      end

      # Adds a ID (based on the time when submitted) to sequences that are not
      #  in fasta format.
      def ensure_fasta_valid
        sequence = @params[:seq].lstrip
        if sequence[0] != '>'
          logger.debug('Adding an ID to sequences.')
          inserted_id = ">Submitted: #{Time.now.strftime('%H:%M-%B_%d_%Y')}\n"
          sequence.insert(0, inserted_id)
        end
        @params[:seq] = sequence
      end

      def check_seq_length
        return unless config[:max_characters] != 'undefined'
        return if @params[:seq].length < config[:max_characters]
        fail ArgumentError, 'The input sequence is too long.'
      end

      # Writes the input sequences to a file with the sub_dir in the temp_dir
      def write_seqs_to_file
        logger.debug("Writing input seqs to: '#{@params[:input_file]}'")
        File.open(@params[:input_file], 'w+') { |f| f.write(@params[:seq]) }
        return if File.exist?(@params[:input_file])
        fail 'NpHMMerApp was unable to create the input file.'
      end

      def copy_uploaded_file
        file = File.join(NpHMMerApp.public_dir, 'NpHMMer','uploaded_files_tmp', 
                                  "#{@params['file_uuid']}.fa")
        FileUtils.mv(file, @params[:input_file])
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
          input: @params[:input_file],
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
