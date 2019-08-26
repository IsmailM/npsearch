# frozen_string_literal: true

require 'forwardable'
require 'open3'
require 'timeout'

# Top level module / namespace.
module NpSearch
  # A class to hold sequence data
  class Signalp
    class << self
      extend Forwardable
      def_delegators NpSearch, :opt, :logger

      SP_HEADERS = %w[name cmax cmax_pos ymax ymax_pos smax smax_pos smean d
                      sp dmaxcut networks orf].freeze

      def analyse_sequence(seq, idx)
        sp_results = []
        seqs       = setup_analysis(seq)
        seqs.each { |sequence| sp_results << run_signalp(sequence, idx) }
        sp_results = sp_results.sort_by { |h| h[:d] }.reverse[0]
        logger.debug "-- Signalp: '[#{idx}]' - SP_out: #{sp_results}"
        sp_results
      end

      private

      def run_signalp(seq, idx)
        # Timeout if takes longer than 5 mins
        Timeout.timeout(300) do
          out = run_sp_cmd(seq, idx)
          result = out[0] + ' ' + seq
          return Hash[SP_HEADERS.map(&:to_sym).zip(result.split)]
        end
      rescue Timeout::Error
        logger.debug "-- Signalp: '[#{idx}]' - Timeout"
        no_results = [0, 0, 1, 1, 1, 1, 1, 1, 1, 'F', 1, 1, seq]
        Hash[SP_HEADERS.map(&:to_sym).zip(no_results)]
      end

      def run_sp_cmd(_seq, idx)
        stdin, stdout, stderr = Open3.popen3(signalp_cmd)
        logger.debug "-- Signalp: '[#{idx}]' - '#{[stdin, stdout, stderr]}'"
        out = stdout.gets(nil).split("\n").delete_if { |l| l[0] == '#' }
        return out unless out.nil? || out.empty?

        raise ArgumentError, 'Signalp failed to run sucessfully :('
      ensure
        stdin.close; stdout.close; stderr.close
      end

      def signalp_cmd
        cmd = "echo '>seq\n#{seq}\n' | #{opt[:signalp_path]} -t euk" \
              ' -f short -U 0.34 -u 0.34'
        logger.debug "-- Signalp: '[#{idx}]' - Running: '#{cmd}'"
        cmd
      end

      def setup_analysis(seq)
        orfs = seq.scan(/(?=(M\w{#{opt[:min_orf_length]},}))./).flatten
        opt[:type] == :protein || orfs.empty? || orfs.nil? ? [seq] : orfs
      end
    end
  end
end
