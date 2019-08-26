# frozen_string_literal: true

require 'forwardable'

# Define Config class.
module NpSearchHmmApp
  # Capture our configuration system.
  class Config
    extend Forwardable

    def_delegators NpSearchHmmApp, :logger

    def initialize(data = {})
      @data        = symbolise data
      @config_file = @data.delete(:config_file) || default_config_file
      @config_file = Pathname.new(@config_file).expand_path
      @data = parse_config_file.update @data
      @data = defaults.update @data
    end

    attr_reader :data, :config_file

    # Get.
    def [](key)
      data[key]
    end

    # Set.
    def []=(key, value)
      data[key] = value
    end

    # Exists?
    def include?(key)
      data.include? key
    end

    # Write config data to config file.
    def write_config_file
      return unless config_file

      File.open(config_file, 'w') do |f|
        f.puts(data.delete_if { |_, v| v.nil? }.to_yaml)
      end
    end

    private

    # Symbolizes keys.
    def symbolise(data)
      return {} unless data

      # Symbolize keys.
      Hash[data.map { |k, v| [k.to_sym, v] }]
    end

    # Parses and returns data from config_file if it exists. Returns {}
    # otherwise.
    def parse_config_file
      unless file? config_file
        logger.debug "Configuration file not found: #{config_file}"
        return {}
      end

      logger.debug "Reading configuration file: #{config_file}."
      symbolise YAML.load_file(config_file)
    rescue StandardError => e
      raise CONFIG_FILE_ERROR.new(config_file, e)
    end

    def file?(file)
      file && File.exist?(file) && File.file?(file)
    end

    # Default configuration data.
    def defaults
      {
        num_threads: 1,
        port: 4567,
        host: '0.0.0.0',
        npsearch_app_dir: File.join(Dir.home, '.npsearch_hmm_app/'),
        max_characters: 'undefined',
        ssl: false
      }
    end

    def default_config_file
      '~/.npsearch_hmm_app.conf'
    end
  end
end
