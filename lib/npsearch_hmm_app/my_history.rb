# frozen_string_literal: true

require 'forwardable'
require 'oj'
require 'pathname'

# Relayer Namespace
module NpSearchHmmApp
  # Class to create the history
  class History
    class << self
      extend Forwardable

      def_delegators NpSearchHmmApp, :logger, :users_dir

      def run(email)
        # require 'pry'
        # binding.pry
        generate_history(email)
      end

      def generate_history(email)
        user_dir = Pathname.new(users_dir) + Pathname.new(email)
        return [] unless user_dir.exist?

        data = []
        user_dir.children(false).each do |time|
          next unless time.to_s.length == 33

          json_file = user_dir + time + 'params.oj.json'
          next unless json_file.exist?

          data << generate_data_hash(json_file, user_dir, time)
        end
        data.sort_by { |d| d[:run_time] }.reverse
      end

      def generate_data_hash(json_file, user_dir, time)
        data = Oj.load_file(json_file.to_s)
        data[:run_time] = Time.strptime(data[:uniq_result_id],
                                        '%Y-%m-%d_%H-%M-%S_%L-%N')
        data[:share] = true if (user_dir + time + '.share').exist?
        data
      end
    end
  end
end
