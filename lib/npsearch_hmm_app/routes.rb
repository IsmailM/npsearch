require "base64"
require 'json'
require 'fileutils'
require 'sinatra/base'
require 'slim'

require 'npsearch_hmm_app/run_analysis'
require 'npsearch/version'

module NpSearchHmmApp
  # The Sinatra Routes
  class Routes < Sinatra::Base
    # See http://www.sinatrarb.com/configuration.html
    configure do
      # We don't need Rack::MethodOverride. Let's avoid the overhead.
      disable :method_override

      # Ensure exceptions never leak out of the app. Exceptions raised within
      # the app must be handled by the app. We do this by attaching error
      # blocks to exceptions we know how to handle and attaching to Exception
      # as fallback.
      disable :show_exceptions, :raise_errors

      # Make it a policy to ump to 'rack.errors' any exception raised by the
      # app so that error handlers don't have to do it themselves. But for it
      # to always work, Exceptions defined by us should not respond to `code`
      # or http_status` methods. Error blocks errors must explicitly set http
      # status, if needed, by calling `status` method.
      enable :dump_errors

      # We don't want Sinatra do setup any loggers for us. We will use our own.
      set :logging, nil

      # This is the app root...
      set :root, -> { NpSearchHmmApp.root }

      # This is the full path to the public folder...
      set :public_folder, -> { NpSearchHmmApp.public_dir }
    end

    helpers do
      # Overide default URI helper method - to hardcode a https://
      # In our setup, we are running passenger on http:// (not secure) and then
      # reverse proxying that onto a 443 port (i.e. https://)
      # Generates the absolute URI for a given path in the app.
      # Takes Rack routers and reverse proxies into account.
      def uri(addr = nil, absolute = true, add_script_name = true)
        return addr if addr =~ /\A[a-z][a-z0-9\+\.\-]*:/i
        uri = [host = '']
        if absolute
          host << (NpSearchHmmApp.ssl? ? 'https://' : 'http://')
          if request.forwarded? || request.port != (request.secure? ? 443 : 80)
            host << request.host_with_port
          else
            host << request.host
          end
        end
        uri << request.script_name.to_s if add_script_name
        uri << (addr ? addr : request.path_info).to_s
        File.join uri
      end

      def host_with_port
        forwarded = request.env['HTTP_X_FORWARDED_HOST']
        if forwarded
          forwarded.split(/,\s?/).last
        else
          request.env['HTTP_HOST'] || "#{request.env['SERVER_NAME'] ||
            request.env['SERVER_ADDR']}:#{request.env['SERVER_PORT']}"
        end
      end

      # Remove port number.
      def host
        host_with_port.to_s.sub(/:\d+\z/, '')
      end

      def base_url
        @base_url ||= "#{NpSearchHmmApp.ssl? ? 'https' : 'http'}://#{host}"
      end
    end

    configure do
      set :uploaded_files, []
    end

    # For any request that hits the app, log incoming params at debug level.
    before do
      logger.debug params
    end

    # Set up global variables for the templates...
    before '/' do
      @max_characters = NpSearchHmmApp.config[:max_characters]
    end

    get '/' do
      slim :search
    end

    post '/api/analyse' do
      params[:user] = 'npsearch'
      email = Base64.decode64(params[:user])
      @nphmmer_results = RunNpHMMer.run(params, email, base_url)
      slim :results, layout: false
    end

    post '/api/upload' do
      dir = File.join(NpSearchHmmApp.tmp_dir, params[:qquuid])
      FileUtils.mkdir(dir) unless File.exist?(dir)
      fname = params[:qqfilename].to_s
      fname += ".part_#{params[:qqpartindex]}" unless params[:qqtotalparts].nil?
      FileUtils.cp(params[:qqfile][:tempfile].path, File.join(dir, fname))
      { success: true }.to_json
    end

    post '/api/uploaddone' do
      parts = params[:qqtotalparts].to_i - 1
      fname = params[:qqfilename]
      dir   = File.join(NpSearchHmmApp.tmp_dir, params[:qquuid])
      files = (0..parts).map { |i| File.join(dir, "#{fname}.part_#{i}") }
      system("cat #{files.join(' ')} > #{File.join(dir, fname)}")
      if $CHILD_STATUS.exitstatus.zero?
        system("rm #{files.join(' ')}")
        { success: true }.to_json
      else
        { success: false }.to_json
      end
    end

    # This error block will only ever be hit if the user gives us a funny
    # sequence or incorrect advanced parameter. Well, we could hit this block
    # if someone is playing around with our HTTP API too.
    error RunNpHMMer::ArgumentError, RunNpHMMer::RuntimeError do
      status 400
      slim :"500", layout: false
    end

    # This will catch any unhandled error and some very special errors. Ideally
    # we will never hit this block. If we do, there's a bug in NpSearchHmmApp
    # or something really weird going on.
    # TODO: If we hit this error block we show the stacktrace to the user
    # requesting them to post the same to our Google Group.
    error Exception do
      status 500
      slim :"500", layout: false
    end

    not_found do
      status 404
      slim :"404", layout: false
    end
  end
end
