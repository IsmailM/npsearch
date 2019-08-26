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

      def all_hmms(email)
        default_hmm_path = NpSearchHmmApp.data_dir + 'hmm'
        unless email.empty?
          custom_hmm_path = NpSearchHmmApp.users_dir + email + 'hmms' + 'hmm'
        end
        {
          default: generate_hmm_hash(default_hmm_path),
          custom: email.empty? ? nil : generate_hmm_hash(custom_hmm_path)
        }
      end

      def single_model(params, email)
        path = if params[:model_name].include?('__NpSearch__')
                 NpSearchHmmApp.users_dir + email + 'hmms' + 'hmm'
               else
                 NpSearchHmmApp.data_dir + 'hmm'
               end
        file_path = path + "#{params[:model_name]}.hmm"
        parse_single_file(file_path)
      end

      def parse_name(basename)
        basename = basename.to_s
        if basename.match? '__NpSearch__'
          basename = basename.split('__NpSearch__').first
        end
        basename.gsub('_', ' / ').tr('-', ' ')
                .gsub(/.aln$/, '').gsub(/.fa$/, '')
      end

      private

      def generate_hmm_hash(dir)
        hmm_files = Pathname.new(dir).glob('*.hmm')
        hmm_files.map { |f| parse_single_file(f) }
      end

      def parse_single_file(file)
        data = parse_hmm_header(file)
        basename = file.basename('.hmm').to_s
        paths = file_paths(file)
        f_links = file_links(basename)
        generate_single_hmm_hash(data, basename, paths, f_links)
      end

      def generate_single_hmm_hash(data, basename, paths, file_links)
        {
          original_name: basename, path: paths, name: parse_name(basename),
          Nsequences: data['NSEQ'].nil? ? '-' : data['NSEQ'].to_i,
          model_length: data['LENG'].nil? ? 0 : data['LENG'].to_i,
          date_generated: data['DATE'].nil? ? '-' : data['DATE'],
          direct_link: "/hmms/#{basename}", file_link: file_links
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

      def file_links(basename)
        {
          hmm: "/hmm_file/hmm/#{basename}",
          alignment: "/hmm_file/alignment/#{basename}",
          fasta: "/hmm_file/fasta/#{basename}"
        }
      end

      def parse_hmm_header(file)
        IO.foreach(file).first(13).map { |e| e.chomp.split(' ', 2) }.to_h
      end
    end
  end
end
