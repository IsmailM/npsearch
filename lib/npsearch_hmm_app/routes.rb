require 'json'
require 'fileutils'
require 'sinatra/base'
require 'slim'

require 'npsearch/version'

module NpHMMerApp
  # The Sinatra Routes
  class Routes < Sinatra::Base

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
      set :root, -> { NpHMMerApp.root }

      # This is the full path to the public folder...
      set :public_folder, -> { NpHMMerApp.public_dir }
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
      @max_characters = NpHMMerApp.config[:max_characters]
    end

    get '/' do
      slim :search
    end

    post '/' do
      RunNpHMMer.init(request.url, params)
      @nphmmer_results = RunNpHMMer.run
      slim :results, layout: false
    end

    post '/upload' do
      if params[:qqtotalparts].nil?
        temp_filename       = "#{params[:qquuid]}.fa"
      else
        temp_filename       = "#{params[:qquuid]}.part_#{params[:qqpartindex]}"
      end
      temp_file_full_path = File.join(NpHMMerApp.public_dir, 'NpHMMer',
                                      'uploaded_files_tmp', temp_filename)
      FileUtils.cp(params[:qqfile][:tempfile].path, temp_file_full_path)
      { success: true }.to_json
    end

    post '/uploaddone' do
      parts = params[:qqtotalparts].to_i - 1
      uuid  = params[:qquuid]
      dir   = File.join(NpHMMerApp.public_dir, 'NpHMMer', 'uploaded_files_tmp')
      files = (0..parts).map { |i| File.join(dir, "#{uuid}.part_#{i}") }
      system("cat #{files.join(' ')} > #{File.join(dir, "#{uuid}.fa")}")
      if $CHILD_STATUS.exitstatus == 0
        system("rm #{files.join(' ')}")
        { success: true}.to_json
      else
        { success: false}.to_json
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
    # we will never hit this block. If we do, there's a bug in NpHMMerApp
    # or something really weird going on.
    # TODO: If we hit this error block we show the stacktrace to the user
    # requesting them to post the same to our Google Group.
    error Exception do
      status 500
      slim :"500", layout: false
    end

    not_found do
      status 404
      slim :"500" # TODO: Create another Template
    end
  end
end
