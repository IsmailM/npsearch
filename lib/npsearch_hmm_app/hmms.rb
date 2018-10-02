# frozen_string_literal: true

require 'forwardable'
require 'oj'
require 'pathname'

# Relayer Namespace
module NpSearchHmmApp
  # Class to create the history
  class HiddenMarkovModels
    class << self
      extend Forwardable

      def_delegators NpSearchHmmApp, :logger, :users_dir

      def add_new(params, user, path)
        init(params, user)
        if @params[:unaligned] == 'on'
          add_fasta_sequence
        elsif @params[:aligned] == 'on'
          add_alignment
        end
      end

      private


      # Setting the scene
      def init(params, user)
        # Using JSON parse to symbolize all keys
        params[:files] = params[:files].nil? ? [] : JSON.parse(params[:files])
        @params = JSON.parse(params.to_json, symbolize_names: true)
        uniq_time = Time.new.strftime('%Y-%m-%d_%H-%M-%S_%L-%N').to_s
        @basename = @params[:name] + '__NpSearch__' + uniq_time
        setup_hmm_dir(user)
      end

      def setup_hmm_dir(user)
        hmms_dir = users_dir + user + 'hmms'
        @hmm_dir = hmms_dir + 'hmm'
        @alignments_dir = hmms_dir + 'alignment'
        @raw_data_dir = hmms_dir + 'raw_data'
        return if @hmm_dir.exist?
        FileUtils.mkdir_p(@hmm_dir)
        FileUtils.mkdir(@alignments_dir)
        FileUtils.mkdir_p(@raw_data_dir)
      end

      def add_fasta_sequence
        in_file = @raw_data_dir + "#{@basename}.fa"
        @params[:files].empty? ? write_seqs(in_file) : move_uploaded(in_file)
        # run_alignment
        # run_hmm
      end

      def add_alignment
        in_file = @raw_data_dir + "#{@basename}.aligned.fa"
        @params[:files].empty? ? write_seqs(in_file) : move_uploaded(in_file)
        # run_hmm
      end

      def write_seqs(file)
        data = @params[:unaligned] == 'on' ? :unaligned_seq : :aligned_seq
        logger.debug("Writing input seqs to: '#{file}'")
        File.open(file, 'w+') { |f| f.write(@params[data]) }
        return if file.exist?
        raise 'NpSearchHmmApp was unable to create the input file.'
      end

      def move_uploaded(file)
        @params[:files].each do |f|
          t_dir = tmp_dir + f[:uuid]
          t_input_file = t_dir + f[:originalName]
          FileUtils.mv(t_input_file, file)
          next unless (Dir.entries(t_dir) - %w[. ..]).empty?
          FileUtils.rm_r(t_dir)
        end
      end

    end
  end
end
