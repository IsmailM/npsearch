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

      def default_hmms
        dafault_hmm_path = NpSearchHmmApp.data_dir + 'hmm'
        generate_hmm_hash(dafault_hmm_path, 'default')
      end

      def custom_hmms(email)
        hmm_path = NpSearchHmmApp.users_dir + email + 'hmm'
        generate_hmm_hash(hmm_path, 'custom')
      end

      def single_model(params, email)
        path = if params[:type] == 'default'
                 NpSearchHmmApp.data_dir + 'hmm'
               else
                 NpSearchHmmApp.users_dir + email + 'hmm'
               end
        file_path = path + "#{params[:model_name]}.hmm"
        parse_single_file(file_path, params[:type])
      end

      private

      def generate_hmm_hash(dir, type)
        hmm_files = Pathname.new(dir).glob('*.hmm')
        hmm_files.map { |f| parse_single_file(f, type) }
      end

      def parse_single_file(file, type)
        data = parse_hmm_header(file)
        basename = file.basename('.hmm').to_s
        paths = file_paths(file)
        alignment = parse_alignment_file(paths[:alignment])
        generate_single_hmm_hash(data, basename, paths, type, alignment)
      end

      def generate_single_hmm_hash(data, basename, paths, type, alignment)
        {
          original_name: basename, path: paths, type: type,
          name: basename.gsub('_', ' / ').tr('-', ' '),
          alignment_sequences: alignment,
          Nsequences: data['NSEQ'].nil? ? '-' : data['NSEQ'].to_i,
          model_length: data['LENG'].nil? ? 0 : data['LENG'].to_i,
          date_generated: data['DATE'].nil? ? '-' : data['DATE'],
          direct_link: "/hmms/#{type}/#{basename}",
          file_link: {
            hmm: "/hmm_file/#{type}/hmm/#{basename}",
            alignment: "/hmm_file/#{type}/alignment/#{basename}",
            fasta: "/hmm_file/#{type}/fasta/#{basename}"
          }
        }
      end

      def file_paths(hmm_file)
        basename = hmm_file.basename('.hmm')
        dir = hmm_file.dirname.dirname
        {
          hmm: hmm_file,
          alignment: Pathname.glob("#{dir + 'alignments'}/#{basename}*")&.first,
          fasta: Pathname.glob("#{dir + 'raw_data'}/#{basename}*")&.first
        }
      end

      def parse_hmm_header(file)
        IO.foreach(file).first(13).map { |e| e.chomp.split(' ', 2) }.to_h
      end

      def parse_alignment_file(alignment_file)
        return unless alignment_file.exist?
        File.read(alignment_file)
      end
    end
  end
end
