# frozen_string_literal: true

require 'base64'
require 'bigdecimal'
require 'forwardable'
require 'oj'

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
      def run(params, user)
        init(params, user)
        @output_results = run_nphmmer
        @results = generate_results_hash
        write_results_to_file
        @results
      # rescue StandardError
      #   raise 'NpHMMer failed to run successfully. Please contact me at ' \
      #         'ismail.moghul@gmail.com'
      end

      private

      # Setting the scene
      def init(params, user)
        # Using JSON parse to symbolize all keys
        params[:files] = JSON.parse(params[:files])
        @params = JSON.parse(params.to_json, symbolize_names: true)
        @email = user
        assert_params
        @uniq_time = Time.new.strftime('%Y-%m-%d_%H-%M-%S_%L-%N').to_s
        setup_run_dir
      # rescue StandardError
      #   raise 'NpHMMer failed to initialise the analysis successfully. '\
      #         'Please contact me at ismail.moghul@gmail.com'
      end

      def assert_params
        # && assert_files && assert_files_exists
        raise ArgumentError, 'Failed to upload files' unless assert_param_exist
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

      def setup_run_dir
        @run_dir = users_dir + @email + @uniq_time
        @run_files_dir = @run_dir + 'input_files'
        tmp_dir = @run_dir + 'tmp'
        logger.debug("Creating Run Directory: #{@run_dir}")
        FileUtils.mkdir_p(@run_files_dir)
        FileUtils.mkdir_p(tmp_dir)
        @input_files = @params[:files].empty? ? write_seqs : move_uploaded
      end

      def move_uploaded
        @params[:files].each do |f|
          t_dir = tmp_dir + f[:uuid]
          t_input_file = t_dir + f[:originalName]
          f = @run_files_dir + f[:originalName]
          FileUtils.mv(t_input_file, f)
          next unless (Dir.entries(t_dir) - %w[. ..]).empty?
          FileUtils.rm_r(t_dir)
        end
        @params[:files].map { |f| @run_files_dir + f[:originalName] }
      end

      # Writes the input sequences to a file with the sub_dir in the temp_dir
      def write_seqs
        fname = @run_files_dir + 'pasted_sequences.fa'
        logger.debug("Writing input seqs to: '#{fname}'")
        File.open(fname, 'w+') { |f| f.write(@params[:seq]) }
        return [fname] if fname.exist?
        raise 'NpSearchHmmApp was unable to create the input file.'
      end

      def run_nphmmer
        @input_files.map do |file|
          nphmmer_opt = init_nphmmer_arguments(file)
          logger.debug("NpHMMer OPTS: #{nphmmer_opt}")
          NpHMMer.init(nphmmer_opt)
          NpHMMer::Hmmer.search
          result = NpHMMer::Hmmer.analyse_output
          sorted_result = result.sort_by { |seq| BigDecimal(seq.lowest_evalue) }
          { filename: file, results: sorted_result, opt: nphmmer_opt }
        end
      end

      def init_nphmmer_arguments(file)
        {
          temp_dir:  @run_dir + 'tmp' + "#{File.basename(file)}_hmmsearch_out",
          input: file,
          num_threads: config[:num_threads],
          evalue: @params[:evalue],
          hmm_models_dir: hmm_models_dirs,
          filter_hmm_list: hmm_model_files,
          signalp_path: @params[:signalp] == 'on' ? config[:signalp_path] : nil,
          deep_analysis: @params[:deep_hmm] == 'on' ? true : nil
        }
      end

      def hmm_models_dirs
        dir = NpSearchHmmApp.data_dir + 'hmm'
        if @email == 'npsearch'
          [dir]
        else
          user_hmm_dir = NpSearchHmmApp.users_dir + @email + 'hmms' + 'hmm'
          [dir, user_hmm_dir]
        end
      end

      def hmm_model_files
        return nil if @params[:all_hmms] == 'on'
        [@params[:default_hmm], @params[:custom_hmm]].flatten
      end

      def create_log_file
        @log_file = @run_dir + 'log_file.txt'
        logger.debug("Log file: #{@log_file}")
      end

      def write_results_to_file
        params_file = @run_dir + 'params.oj.json'
        logger.debug("writing params file to #{params_file}")
        Oj.to_file(params_file.to_s, @results)
      end

      def generate_results_hash
        {
          results: @output_results,
          params: @params,
          user: encode_email,
          results_url: "/result/#{encode_email}/#{@uniq_time}",
          share_url: "/sh/#{encode_email}/#{@uniq_time}",
          full_path: @run_dir,
          uniq_result_id: @uniq_time
        }
      end

      def encode_email
        Base64.encode64(@email).chomp
      end
    end
  end
end
