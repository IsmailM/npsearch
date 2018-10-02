# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require 'yaml'

require 'npsearch_hmm_app/config'
require 'npsearch_hmm_app/exceptions'
require 'npsearch_hmm_app/logger'
require 'npsearch_hmm_app/routes'
require 'npsearch_hmm_app/server'

module NpSearchHmmApp
  MIN_HMMER_VERSION = '3.0.0'

  class << self
    def environment
      ENV['RACK_ENV']
    end

    def verbose?
      true
    end

    def root
      Pathname.new(__dir__).dirname + 'app'
    end

    def data_dir
      Pathname.new(__dir__).dirname + 'data'
    end

    def ssl?
      @config[:ssl]
    end

    def logger
      @logger ||= Logger.new(STDERR, verbose?)
    end

    # Setting up the environment before running the app...
    # We don't validate port and host settings. If GeoDiver is run
    # self-hosted, bind will fail on incorrect values. If GeoDiver
    # is run via Apache/Nginx + Passenger, we don't need to worry.
    def init(config = {})
      @config = Config.new(config)

      init_binaries
      init_dirs
      check_num_threads
      check_max_characters
      self
    end

    # default serve_dir   = $HOME/.npsearch_hmm_app/
    # default public_dir  = $HOME/.npsearch_hmm_app/public/
    # default users_dir   = $HOME/.npsearch_hmm_app/users/
    # default tmp_dir     = $HOME/.npsearch_hmm_app/tmp/

    attr_reader :config, :public_dir, :users_dir, :tmp_dir

    # Starting the app manually
    def run
      check_host
      Server.run(self)
    rescue Errno::EADDRINUSE
      puts "** Could not bind to port #{config[:port]}."
      puts "   Is NpSearch already accessible at #{server_url}?"
      puts '   No? Try running NpSearch on another port, like so:'
      puts
      puts '       npsearch app -p 4570.'
    rescue Errno::EACCES
      puts "** Need root privilege to bind to port #{config[:port]}."
      puts '   It is not advisable to run NpSearch as root.'
      puts '   Please use Apache/Nginx to bind to a privileged port.'
    end

    def on_start
      puts '** NpSearch-HMM app is ready.'
      puts "   Go to #{server_url} in your browser and start analysing NeuroPeptides!"
      puts '   Press CTRL+C to quit.'
      open_in_browser(server_url)
    end

    def on_stop
      puts
      puts '** Thank you for using NpSearch :).'
      puts '   Please cite: '
      puts '        Moghul et al. (in prep).' \
           ' NpSearch: Identify Neuropeptide Precursors.'
    end

    # Rack-interface.
    #
    # Inject our logger in the env and dispatch request to our controller.
    def call(env)
      env['rack.logger'] = logger
      Routes.call(env)
    end

    # Run GeoDiver interactively.
    def irb
      # rubocop:disable Lint/Debugger
      ARGV.clear
      require 'pry'
      binding.pry
      # rubocop:enable Lint/Debugger
    end

    private

    # Set up the directory structure in @config[:gd_public_dir]
    def init_dirs
      config[:serve_dir] = Pathname.new(config[:serve_dir]).expand_path
      logger.debug "NpSearch Directory: #{config[:serve_dir]}"
      init_public_dir
      init_tmp_dir
      init_users_dir
      set_up_default_user_dir
    end

    def init_public_dir
      @public_dir = config[:serve_dir] + 'public'
      logger.debug "public_dir Directory: #{@public_dir}"
      FileUtils.mkdir_p @public_dir unless @public_dir.exist?
      init_assets(NpSearchHmmApp.root + 'public/assets',
                  @public_dir + 'assets')
    end

    def init_assets(root_assets, assets)
      if environment == 'production'
        css = assets + 'css' + "style-#{NpSearch::VERSION}.min.css"
        FileUtils.rm_rf(assets) if assets.symlink? || !css.exist?
        FileUtils.cp_r(root_assets, @public_dir) unless assets.exist?
      else
        FileUtils.rm_rf(assets) unless assets.symlink?
        FileUtils.ln_s(root_assets, @public_dir) unless assets.exist?
      end
    end

    def init_tmp_dir
      @tmp_dir = config[:serve_dir] + 'tmp'
      logger.debug "tmp_dir Directory: #{@tmp_dir}"
      FileUtils.mkdir_p @tmp_dir unless @tmp_dir.exist?
    end

    def init_users_dir
      @users_dir = config[:serve_dir] + 'users'
      logger.debug "users_dir Directory: #{@users_dir}"
      FileUtils.mkdir_p @users_dir unless @users_dir.exist?
    end

    def set_up_default_user_dir
      default_user_dir = NpSearchHmmApp.users_dir + 'npsearch'
      FileUtils.mkdir default_user_dir unless default_user_dir.exist?
    end

    def init_binaries
      config[:bin] = init_bins if config[:bin]
      assert_hmmer_installed_and_compatible
    end

    def check_num_threads
      config[:num_threads] = Integer(config[:num_threads])
      raise NUM_THREADS_INCORRECT unless config[:num_threads].positive?

      logger.debug "Will use #{config[:num_threads]} threads to run GeoDiver."
      return unless config[:num_threads] > 256
      logger.warn "Number of threads set at #{config[:num_threads]} is" \
                  ' unusually high.'
    end

    def check_max_characters
      if config[:max_characters] != 'undefined'
        config[:max_characters] = Integer(config[:max_characters])
      end
    rescue StandardError
      raise MAX_CHARACTERS_INCORRECT
    end

    def init_bins
      bins = []
      config[:bin].each do |bin|
        bins << File.expand_path(bin)
        unless File.exist?(bin) && File.directory?(bin)
          raise BIN_DIR_NOT_FOUND, config[:bin]
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

    def assert_hmmer_installed_and_compatible
      raise HMMER_NOT_INSTALLED unless command? 'hmmsearch'
      # version = `hmmsearch -version`.split[1]
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
      host = 'localhost' if ['127.0.0.1', '0.0.0.0'].include? host
      proxy = NpSearchHmmApp.ssl? ? 'https' : 'http'
      "#{proxy}://#{host}:#{config[:port]}"
    end

    def open_in_browser(server_url)
      return if using_ssh? || verbose?
      if RUBY_PLATFORM =~ /linux/ && xdg?
        system "xdg-open #{server_url}"
      elsif RUBY_PLATFORM.match?(/darwin/)
        system "open #{server_url}"
      end
    end

    def using_ssh?
      true if ENV['SSH_CLIENT'] || ENV['SSH_TTY'] || ENV['SSH_CONNECTION']
    end

    def xdg?
      true if ENV['DISPLAY'] && system('which xdg-open > /dev/null 2>&1')
    end

    # Return `true` if the given command exists and is executable.
    def command?(command)
      system("which #{command} > /dev/null 2>&1")
    end
  end
end
