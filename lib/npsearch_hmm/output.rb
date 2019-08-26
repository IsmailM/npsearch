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
        output_dir = output_directory_name
        FileUtils.mkdir_p(output_dir)
        copy_html_folder(output_dir)
        output_dir
      end

      def to_fasta(hmm_results, output_dir)
        basename = File.basename(opt[:input_file], '.*')
        out = File.join(output_dir, "#{basename}.npsearch.out.fa")
        File.open(out, 'w') do |file|
          hmm_results.each do |seq|
            file.puts '>' + seq.def_line + "\n" + seq.seq
          end
        end
      end

      def to_html(output_dir)
        template = File.expand_path('../../app/views/single.slim', __dir__)
        contents_temp = File.read(template)
        html = Slim::Template.new { contents_temp }.render(NpHMMer)
        basename = File.basename(opt[:input_file], '.*')
        out = File.join(output_dir, "#{basename}.npsearch.out.html")
        File.open(out, 'w') { |f| f.puts html }
      end

      private

      def copy_html_folder(dir)
        html_dir = File.join(dir, 'html_files')
        assets_dir = File.expand_path('../../app/assets/public', __dir__)
        FileUtils.rm_r(html_dir) if File.directory? html_dir
        FileUtils.cp_r(assets_dir, html_dir)
      end

      def output_directory_name
        input_file = opt[:input_file]
        fname = File.basename(input_file, File.extname(input_file))
        dir_name = "#{fname}_" + Time.now.strftime('%Y_%m_%d_%H_%M_%S')
        default_dirname = File.join(Dir.pwd, dir_name)
        opt[:output_dir].nil? ? default_dirname : opt[:output_dir]
      end
    end
  end
end
