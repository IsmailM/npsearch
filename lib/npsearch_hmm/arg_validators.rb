require 'bio'

# Top level module / namespace.
module NpHMMer
  # A class that validates the command line opts
  class ArgumentsValidators
    class << self
      def run(opt)
        assert_file_present('input fasta file', opt[:input])
        opt[:input_file] = File.expand_path(opt[:input])
        assert_input_file_not_empty(opt[:input_file])
        assert_input_file_probably_fasta(opt[:input_file])
        opt[:type] = assert_input_sequence(opt[:input])
        export_bin_dirs(opt[:hmmer_bin]) if opt[:hmmer_bin]
        opt
      end

      private

      def assert_file_present(desc, file, exit_code = 1)
        return if file && File.exist?(File.expand_path(file))
        $stderr.puts "*** Error: Couldn't find the #{desc}: #{file}."
        exit exit_code
      end

      def assert_input_file_not_empty(file)
        return unless File.zero?(File.expand_path(file))
        $stderr.puts "*** Error: The input_file (#{file})" \
                     ' seems to be empty.'
        exit 1
      end

      def assert_input_file_probably_fasta(file)
        File.open(file, 'r') do |f|
          fasta = f.readline[0] == '>' ? true : false
          return fasta if fasta
        end
        $stderr.puts "*** Error: The input_file (#{file})" \
                     ' does not seems to be a fasta file.'
        exit 1
      end

      def assert_input_sequence(file)
        type = type_of_sequences(file)
        return type unless type.nil?
        $stderr.puts '*** Error: The input files seems to contain a mixture of'
        $stderr.puts '    both protein and nucleotide data.'
        $stderr.puts '    Please correct this and try again.'
        exit 1
      end

      # determine file sequence type based on first 500 lines
      def type_of_sequences(file)
        fasta_content = File.foreach(file).first(500).join("\n")
        # the first sequence does not need to have a fasta definition line
        sequences = fasta_content.split(/^>.*$/).delete_if(&:empty?)
        # get all sequence types
        sequence_types = sequences.collect { |seq| guess_sequence_type(seq) }
                                  .uniq.compact
        return nil if sequence_types.empty?
        sequence_types.first if sequence_types.length == 1
      end

      def guess_sequence_type(seq)
        # removing non-letter and ambiguous characters
        cleaned_sequence = seq.gsub(/[^A-Z]|[NX]/i, '')
        return nil if cleaned_sequence.length < 10 # conservative
        type = Bio::Sequence.new(cleaned_sequence).guess(0.9)
        type == Bio::Sequence::NA ? :genetic : :protein
      end

      def export_bin_dirs(hmmer_bin)
        bin = File.expand_path(hmmer_bin)
        if File.exist?(bin) && File.directory?(bin)
          add_to_path(bin)
        else
          $stderr.puts '*** The following bin directory does not exist:'
          $stderr.puts "    #{bin}"
        end
      end

      ## Checks if dir is in $PATH and if not, it adds the dir to the $PATH.
      def add_to_path(bin_dir)
        return unless bin_dir
        return if ENV['PATH'].split(':').include?(bin_dir)
        ENV['PATH'] = "#{bin_dir}:#{ENV['PATH']}"
      end
    end
  end
end
