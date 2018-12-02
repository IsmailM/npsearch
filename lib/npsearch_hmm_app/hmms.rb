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

      def add_new(params, user)
        init(params, user)
        @params[:aligned] == 'no' ? add_fasta_sequence : add_alignment
      end

      private

      # Setting the scene
      def init(params, user)
        # Using JSON parse to symbolize all keys
        params[:files] = params[:files].nil? ? [] : JSON.parse(params[:files])
        @params = JSON.parse(params.to_json, symbolize_names: true)
        uniq_time = Time.new.strftime('%Y-%m-%d_%H-%M-%S_%L-%N').to_s
        @basename = prettify_name(@params[:name]) + '__NpSearch__' + uniq_time
        setup_hmm_dir(user)
      end

      # remove weird characters
      def prettify_name(name)
        name.gsub(%r{[^ a-zA-Z1-9\/-]}, '').gsub(' / ', '_').tr(' ', '-')
      end

      def setup_hmm_dir(user)
        dir = users_dir + user + 'hmms'
        @hmm_dir = dir + 'hmm'
        @alignments_dir = dir + 'alignments'
        @raw_data_dir = dir + 'raw_data'
        return if @hmm_dir.exist?
        FileUtils.mkdir_p(@hmm_dir)
        FileUtils.mkdir(@alignments_dir)
        FileUtils.mkdir_p(@raw_data_dir)
      end

      def add_fasta_sequence
        in_file = @raw_data_dir + "#{@basename}.fa"
        @params[:files].empty? ? write_seqs(in_file) : move_uploaded(in_file)
        run_alignment
        run_hmm
      end

      def add_alignment
        in_file = @alignments_dir + "#{@basename}.aln"
        @params[:files].empty? ? write_seqs(in_file) : move_uploaded(in_file)
        run_hmm
      end

      def write_seqs(file)
        logger.debug("Writing input seqs to: '#{file}'")
        File.open(file, 'w+') { |f| f.write(@params[:seq]) }
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

      def run_alignment
        in_file = @raw_data_dir + "#{@basename}.fa"
        out_file = @alignments_dir + "#{@basename}.aln"
        NpHMMer::Hmmer::Generate.run_mafft(in_file, out_file, 4)
      end

      def run_hmm
        in_file = @alignments_dir + "#{@basename}.aln"
        out_file = @hmm_dir + "#{@basename}.hmm"
        NpHMMer::Hmmer::Generate.run_hmm_build(in_file, out_file, 4)
      end
    end
  end
end
