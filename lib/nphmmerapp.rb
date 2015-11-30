require 'yaml'
require 'fileutils'

require 'nphmmerapp/config'
require 'nphmmerapp/exceptions'
require 'nphmmerapp/nphmmer'
require 'nphmmerapp/logger'
require 'nphmmerapp/routes'
require 'nphmmerapp/server'
require 'nphmmerapp/version'

module NpHMMerApp
  # Use a fixed minimum version of BLAST+
  MIN_HMMER_VERSION = '3.0.0'

  class << self
    def environment
      ENV['RACK_ENV']
    end

    def verbose?
      @verbose ||= (environment == 'development')
    end

    def root
      File.dirname(File.dirname(__FILE__))
    end

    def logger
      @logger ||= Logger.new(STDERR, verbose?)
    end

    # Setting up the environment before running the app...
    def init(config = {})
      @config = Config.new(config)

      init_binaries
      init_dirs
      check_num_threads
      check_max_characters
      self
    end

    attr_reader :config, :temp_dir, :public_dir

    # Starting the app manually
    def run
      check_host
      Server.run(self)
    rescue Errno::EADDRINUSE
      puts "** Could not bind to port #{config[:port]}."
      puts "   Is NpHMMer already accessible at #{server_url}?"
      puts '   No? Try running NpHMMer on another port, like so:'
      puts
      puts '       nphmmerapp -p 4570.'
    rescue Errno::EACCES
      puts "** Need root privilege to bind to port #{config[:port]}."
      puts '   It is not advisable to run NpHMMer as root.'
      puts '   Please use Apache/Nginx to bind to a privileged port.'
    end

    def on_start
      puts '** NpHMMer is ready.'
      puts "   Go to #{server_url} in your browser and start analysing genes!"
      puts '   Press CTRL+C to quit.'
      open_in_browser(server_url)
    end

    def on_stop
      puts
      puts '** Thank you for using NpHMMerApp :).'
      puts '   Please cite: '
      puts '        Moghul et al. (in prep).' \
           ' NpHMMer: identify Neuropeptide Precursors.'
    end

    # Rack-interface.
    #
    # Inject our logger in the env and dispatch request to our controller.
    def call(env)
      env['rack.logger'] = logger
      Routes.call(env)
    end

    private

    def init_dirs
      config[:public_dir] = File.expand_path(config[:public_dir])
      unique_start_id     = 'NH_' + "#{Time.now.strftime('%Y%m%d-%H-%M-%S')}"
      @public_dir         = File.join(config[:public_dir], unique_start_id)
      init_public_dir
    end

    # Create the Public Dir and copy files from gem root - this public dir
    #   is served by the app is accessible at URL/...
    def init_public_dir
      FileUtils.mkdir_p(File.join(@public_dir, 'NpHMMer'))
      root_web_files = File.join(NpHMMerApp.root, 'public/web_files')
      root_gv        = File.join(NpHMMerApp.root, 'public/NpHMMer')
      FileUtils.cp_r(root_web_files, @public_dir)
      FileUtils.cp_r(root_gv, @public_dir)
    end

    def init_binaries
      config[:bin] = init_bins if config[:bin]
      assert_blast_installed_and_compatible
    end

    def check_num_threads
      num_threads = Integer(config[:num_threads])
      fail NUM_THREADS_INCORRECT unless num_threads > 0

      logger.debug "Will use #{num_threads} threads to run BLAST."
      if num_threads > 256
        logger.warn "Number of threads set at #{num_threads} is unusually high."
      end
    rescue
      raise NUM_THREADS_INCORRECT
    end

    def check_max_characters
      if config[:max_characters] != 'undefined'
        config[:max_characters] = Integer(config[:max_characters])
      end
    rescue
      raise MAX_CHARACTERS_INCORRECT
    end

    def init_bins
      bins = []
      config[:bin].each do |bin|
        bins << File.expand_path(bin)
        unless File.exist?(bin) && File.directory?(bin)
          fail BIN_DIR_NOT_FOUND, config[:bin]
        end
        export_bin_dir(bin)
      end
      bins
    end

    ## Checks if dir is in $PATH and if not, it adds the dir to the $PATH.
    def export_bin_dir(bin_dir)
      return unless bin_dir
      return if ENV['PATH'].split(':').include?(bin_dir)
      ENV['PATH'] = "#{bin_dir}:#{ENV['PATH']}"
    end

    def assert_blast_installed_and_compatible
      fail HMMER_NOT_INSTALLED unless command? 'hmmscan'
      # version = `hmmscan -version`.split[1]
      # fail HMMER_NOT_COMPATIBLE, version unless version >= MIN_HMMER_VERSION
    end

    # Check and warn user if host is 0.0.0.0 (default).
    def check_host
      return unless config[:host] == '0.0.0.0'
      logger.warn 'Will listen on all interfaces (0.0.0.0).' \
                  ' Consider using 127.0.0.1 (--host option).'
    end

    def server_url
      host = config[:host]
      host = 'localhost' if host == '127.0.0.1' || host == '0.0.0.0'
      "http://#{host}:#{config[:port]}"
    end

    def open_in_browser(server_url)
      return if using_ssh? || verbose?
      if RUBY_PLATFORM =~ /linux/ && xdg?
        system("xdg-open #{server_url}")
      elsif RUBY_PLATFORM =~ /darwin/
        system("open #{server_url}")
      end
    end

    def using_ssh?
      true if ENV['SSH_CLIENT'] || ENV['SSH_TTY'] || ENV['SSH_CONNECTION']
    end

    def xdg?
      true if ENV['DISPLAY'] && command?('xdg-open')
    end

    # Return `true` if the given command exists and is executable.
    def command?(command)
      system("which #{command} > /dev/null 2>&1")
    end
  end
end
