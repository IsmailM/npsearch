require 'base64'
require 'bigdecimal'
require 'forwardable'
require 'npsearch_hmm'

module NpSearchHmmApp
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

      def_delegators NpSearchHmmApp, :config, :logger, :public_dir, :users_dir,
                     :tmp_dir

      # Writes sequesnces to file and runs NpHMMer
      def run(params, user, url)
        init(params, user)
        run_nphmmer
      # rescue
      #   raise 'NpHMMer failed to run successfully. Please contact me at ' \
      #         'ismail.moghul@gmail.com'
      end

      private

      # Setting the scene
      def init(params, user)
        @params = params
        @email = user
        assert_params
        @uniq_time = Time.new.strftime('%Y-%m-%d_%H-%M-%S_%L-%N').to_s
        setup_run_dir(params)
      # rescue
      #   raise 'NpHMMer failed to initialise the analysis successfully. '\
      #         'Please contact me at ismail.moghul@gmail.com'
      end

      def assert_params
        unless assert_param_exist #&& assert_files && assert_files_exists
          raise ArgumentError, 'Failed to upload files'
        end
        assert_seq_param_present
        ensure_fasta_valid
        check_seq_length
      end

      def assert_param_exist
        !@params.nil?
      end

      # def assert_files
      #   @params[:files].collect { |f| f[:status] == 'upload successful' }.uniq
      # end

      # def assert_files_exists
      #   files = @params[:files].collect do |f|
      #     File.exist?(File.join(tmp_dir, f[:uuid], f[:originalName]))
      #   end
      #   files.uniq
      # end

      # Simply asserts whether that the seq param is present
      def assert_seq_param_present
        return if @params[:seq]
        raise ArgumentError, 'No input sequence provided.'
      end

      # Adds a ID (based on the time when submitted) to sequences that are not
      #  in fasta format.
      def ensure_fasta_valid
        sequence = @params[:seq].lstrip
        if sequence[0] != '>'
          logger.debug('Adding an ID to sequences.')
          inserted_id = ">Submitted #{Time.now.strftime('%H:%M-%B_%d_%Y')}\n"
          sequence.insert(0, inserted_id)
        end
        @params[:seq] = sequence
      end

      def check_seq_length
        return unless config[:max_characters] != 'undefined'
        return if @params[:seq].length < config[:max_characters]
        raise ArgumentError, 'The input sequence is too long.'
      end

      def setup_run_dir(params)
        @run_dir = File.join(users_dir, @email, @uniq_time)
        @run_files_dir = File.join(@run_dir, 'files')
        logger.debug("Creating Run Directory: #{@run_dir}")
        FileUtils.mkdir_p(@run_files_dir)
        @input_files = params[:file_uuid].empty? ? write_seqs : move_uploaded
      end

      def move_uploaded
        @params[:files] = JSON.parse(@params[:files], symbolize_names: true)
        @params[:files].each do |f|
          t_dir = File.join(tmp_dir, f[:uuid])
          t_input_file = File.join(t_dir, f[:originalName])
          f = File.join(@run_files_dir, f[:originalName])
          FileUtils.mv(t_input_file, f)
          next unless (Dir.entries(t_dir) - %w[. ..]).empty?
          FileUtils.rm_r(t_dir)
        end
        @params[:files].map { |f| File.join(@run_files_dir, f[:originalName]) }
      end

      # Writes the input sequences to a file with the sub_dir in the temp_dir
      def write_seqs
        fname = File.join(@run_files_dir, 'input.fa')
        logger.debug("Writing input seqs to: '#{fname}'")
        File.open(fname, 'w+') { |f| f.write(@params[:seq]) }
        return [fname] if File.exist?(fname)
        raise 'NpSearchHmmApp was unable to create the input file.'
      end

      def run_nphmmer
        results = []
        @input_files.each do |file|
          opt = init_nphmmer_arguments(file)
          NpHMMer.init(opt)
          NpHMMer::Hmmer.search
          result = NpHMMer::Hmmer.analyse_output
          results << result.sort_by { |seq| BigDecimal(seq.lowest_evalue) }
        end
        results
      end

      def init_nphmmer_arguments(file)
        opt = {
          temp_dir: File.join(@run_dir, 'tmp'),
          input: file,
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

      def encode_email
        Base64.encode64(@email).chomp
      end
    end
  end
end
