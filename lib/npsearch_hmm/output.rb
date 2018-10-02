# frozen_string_literal: true

require 'forwardable'
require 'slim'

require 'npsearch_hmm/highlight_sequence'

# Top level module / namespace.
module NpHMMer
  # A class that holds methods related to Output
  class Output
    class <<self
      extend Forwardable
      def_delegators NpHMMer, :opt

      def create_output_dir
        output_dir = File.join(File.dirname(opt[:input_file]), 'NpHMMer')
        FileUtils.mkdir_p(output_dir)
        copy_html_folder(output_dir)
        output_dir
      end

      def to_fasta(hmm_results, output_dir)
        basename = File.basename(opt[:input_file], '.*')
        out = File.join(output_dir, "#{basename}.NpHMMer.out.fa")
        File.open(out, 'w') do |file|
          hmm_results.each do |seq|
            file.puts '>' + seq.def_line + "\n" + seq.seq
          end
        end
      end

      def to_html(output_dir)
        template = File.expand_path('../../template/contents.slim', __dir__)
        contents_temp = File.read(template)
        html = Slim::Template.new { contents_temp }.render(NpHMMer)
        basename = File.basename(opt[:input_file], '.*')
        out = File.join(output_dir, "#{basename}.NpHMMer.out.html")
        File.open(out, 'w') { |f| f.puts html }
      end

      private

      def copy_html_folder(dir)
        html_dir = File.join(dir, 'nphmmer.html_files')
        aux_dir  = File.expand_path('../../aux', __dir__)
        FileUtils.rm_r(html_dir) if File.directory? html_dir
        FileUtils.cp_r(aux_dir, html_dir)
      end
    end
  end
end
