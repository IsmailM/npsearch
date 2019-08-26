# frozen_string_literal: true

require 'forwardable'

# Top level module / namespace.
module NpHMMer
  # A class to hold sequence data
  class Signalp
    class << self
      extend Forwardable
      def_delegators NpHMMer, :opt

      def analyse_sequence(seq, hsp_indexes)
        sp_headers = %w[name cmax cmax_pos ymax ymax_pos smax smax_pos smean d
                        sp dmaxcut networks orf]
        data       = setup_analysis(seq, hsp_indexes)
        orf_results = []
        s = `echo "#{data[:fasta]}\n" | #{opt[:signalp_path]} -t euk \
             -f short -U 0.34 -u 0.34`
        sp_results = s.split("\n").delete_if { |l| l[0] == '#' }
        sp_results.each_with_index do |line, idx|
          line = line + ' ' + data[:seq][idx].to_s
          orf_results << Hash[sp_headers.map(&:to_sym).zip(line.split)]
        end
        orf_results.sort_by { |h| h[:d] }.reverse[0]
      end

      def setup_analysis(seq, hsp_indexes)
        if opt[:type] == :protein
          return { seq: [seq.seq], fasta: ">seq\n#{seq.seq}" }
        end

        hsp_start           = hsp_indexes[0][0]
        sequence_before_hsp = seq.seq[0, hsp_start].to_s
        if sequence_before_hsp.include?('M') && sequence_before_hsp.size > 15
          min_length = seq.seq.length - hsp_start - 15
          min_length = 1 if min_length < 0
          orfs = seq.seq.scan(/(?=(M\w{#{min_length},}))./).flatten
          data = { seq: orfs, fasta: create_orf_fasta(orfs) }
        else
          data = { seq: [seq.seq], fasta: ">seq\n#{seq.seq}" }
        end
        data
      end

      def create_orf_fasta(m_orf)
        fasta = ''
        m_orf.each_with_index { |seq, idx| fasta << ">#{idx}\n#{seq}\n" }
        fasta
      end
    end
  end
end
