require 'json'
require 'sinatra/base'
require 'nphmmer/version'
require 'nphmmerapp/version'
require 'slim'

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

      # Make it a policy to dump to 'rack.errors' any exception raised by the
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
      qq_file = settings.uploaded_files.assoc(params['qq-filename'])
      RunNpHMMer.init(request.url, params, qq_file)
      @nphmmer_results = RunNpHMMer.run(qq_file)
      slim :results, layout: false
    end

    post '/upload' do
      uploaded_file = [params[:qqfile][:filename], params[:qqfile][:tempfile]]
      settings.uploaded_files.shift if settings.uploaded_files.length == 10
      settings.uploaded_files.push uploaded_file
      { success: true }.to_json
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
