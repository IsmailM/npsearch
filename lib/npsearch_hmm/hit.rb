# frozen_string_literal: true

require 'bigdecimal'
require 'forwardable'
require 'shellwords' # std ruby lib that escapes shell commands

# Top level module / namespace.
module NpHMMer
  # A class to hold sequence data
  class Hit
    extend Forwardable
    def_delegators NpHMMer, :opt

    attr_reader :id
    attr_reader :def_line
    attr_reader :seq
    attr_reader :hmmer_results
    attr_reader :lowest_evalue
    attr_reader :frame
    attr_reader :translated_seq
    attr_accessor :signalp
    attr_accessor :orf
    attr_accessor :orf_index

    def initialize(id, hmmer_results)
      seq             = extract_seq(id)
      @id             = format_id(id)
      @seq            = format_seq(seq[1])
      @orig_seq       = extract_orig_non_translated_seq(@id, @seq)
      @translated_seq = original_translated_seq(@orig_seq[1], @seq)
      @def_line       = format_id(@orig_seq[0])
      @hmmer_results  = sort_hmmer_results(hmmer_results)
      @lowest_evalue  = @hmmer_results[0][:overall_results][:full_seq_e_value]
    end

    private

    def extract_seq(id)
      file = opt[:type] == :genetic ? opt[:orf] : opt[:input]
      extract_sequence(id, file)
    end

    def format_id(def_line)
      clean_id = def_line.gsub(/\r\n?/, "\n")
      return clean_id if opt[:type] == :protein
      clean_id.split(' ', 2).each_slice(2) do |id, desc|
        return id.gsub(/_\d+$/, '') + ' ' + desc unless desc.nil?
        return id.gsub(/_\d+$/, '')
      end
    end

    def format_seq(seq)
      seq.gsub(/\r?\n/, '')
    end

    def sort_hmmer_results(hmmer_results)
      hmmer_results.sort_by do |h|
        BigDecimal(h[:overall_results][:full_seq_e_value])
      end
    end

    # Extracts the original sequence before translation
    def extract_orig_non_translated_seq(id, seq)
      return [id, seq] if opt[:type] == :protein
      extract_sequence(id, opt[:input])
    end

    def original_translated_seq(original_sequence, seq)
      return nil if opt[:type] == :protein
      fasta = Bio::Sequence::NA.new(original_sequence)
      sequence = nil
      (1..6).each do |f|
        translated = fasta.translate(f).to_s
        next unless translated.include? seq
        sequence = translated
      end
      sequence.nil? ? seq : sequence
    end

    # extract sequence using Seqtk
    def extract_sequence(id, file)
      seq = bash "seqtk subseq '#{file}' <( echo '#{id}')"
      bioseq = Bio::FastaFormat.new(seq)
      [bioseq.definition, bioseq.seq]
    end

    def bash(command)
      `bash -c #{Shellwords.escape(command)}`
    end
  end
end
