require 'base64'
require 'json'
require 'fileutils'
require 'omniauth'
require 'omniauth-google-oauth2'
require 'pathname'
require 'sinatra/base'
require 'sinatra/asset_pipeline'
require 'slim'
require 'slim/smart'

require 'npsearch_hmm_app/my_history'
require 'npsearch_hmm_app/my_hmms'
require 'npsearch_hmm_app/hmms'
require 'npsearch_hmm_app/run_analysis'
require 'npsearch/version'

module NpSearchHmmApp
  # The Sinatra Routes
  class Routes < Sinatra::Base
    # See http://www.sinatrarb.com/configuration.html
    configure do
      # # We don't need Rack::MethodOverride. Let's avoid the overhead.
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

      # Use Rack::Session::Pool over Sinatra default sessions.
      use Rack::Session::Pool, expire_after: 2_592_000 # 30 days

      # Provide OmniAuth the Google Key and Secret Key for Authentication
      use OmniAuth::Builder do
        provider :google_oauth2, ENV['GOOGLE_KEY'], ENV['GOOGLE_SECRET'],
                 provider_ignores_state: true, verify_iss: false
      end

      set :root, -> { Pathname.new(__dir__).dirname.dirname + 'app' }

      set :assets_protocol, :relative
      set :assets_css_compressor, :sass
      set :assets_js_compressor, :uglifier
      set :assets_paths, [File.join(root, 'assets/stylesheets'),
                          File.join(root, 'assets/javascripts')]
      register Sinatra::AssetPipeline
    end

    # For any request that hits the app, log incoming params at debug level.
    before do
      if params['seq'].nil?
        logger.debug params
      else
        logger.debug params.clone.merge!('seq' => 'sequence')
      end
    end

    # Home page (marketing page)
    get '/' do
      redirect '/analyse'
      # slim :index, layout: false
    end

    get '/faq' do
      slim :faq, layout: :app_layout
    end

    get '/analyse' do
      @max_characters = NpSearchHmmApp.config[:max_characters]
      slim :search, layout: :app_layout
    end

    get '/my_results' do
      redirect to('auth/google_oauth2') if session[:user].nil?
      @my_results = History.run(session[:user].info['email'])

      slim :my_results, layout: :app_layout
    end

    get '/my_hmms' do
      @default_hmms = HiddenMarkovModels.default_hmms
      unless session[:user].nil?
        email = session[:user].info['email']
        @custom_hmms = HiddenMarkovModels.custom_hmms(email)
      end
      slim :my_hmms, layout: :app_layout
    end

    get '/hmm/new' do
      redirect to('auth/google_oauth2') if session[:user].nil?
      slim :new_hmm, layout: :app_layout
    end

    get '/hmms/:type/:model_name' do
      if params[:type] != 'default' && session[:user].nil?
        redirect to('auth/google_oauth2')
      end
      email = session[:user].nil? ? '' : session[:user].info['email']
      @model = HiddenMarkovModels.single_model(params, email)
      slim :single_hmm, layout: :app_layout
    end

    get '/hmm_file/:type/:file_type/:model_name' do
      if params[:type] != 'default' && session[:user].nil?
        redirect to('auth/google_oauth2')
      end
      email = session[:user].nil? ? '' : session[:user].info['email']
      @model = HiddenMarkovModels.single_model(params, email)

      file = @model[:path][ @params[:file_type].to_sym ]
      send_file file, filename: file.basename.to_s
    end

    # Individual Result Pages
    ['/sh/:encoded_email/:time', '/result/:encoded_email/:time'].each do |path|
      get path do
        email = Base64.decode64(params[:encoded_email])
        if request.path_info.match?(%r{^/result}) && ((session[:user].nil? &&
          email != 'npsearch') || email != session[:user].info['email'])
          redirect to('auth/google_oauth2')
        end
        slim :single_result, layout: :app_layout
      end

      post path do
        email = Base64.decode64(params[:encoded_email])
        if request.path_info.match?(%r{^/result}) && ((session[:user].nil? &&
          email != 'npsearch') || email != session[:user].info['email'])
          redirect to('auth/google_oauth2')
        end
        f = NpSearchHmmApp.users_dir + email + params['time'] + 'params.oj.json'
        @nphmmer_results = f.exist? ? Oj.load_file(f.to_s) : {}
        NpHMMer.opt = {}
        if @nphmmer_results[:params][:signalp] == 'on'
          NpHMMer.opt[:signalp_path] = NpSearchHmmApp.config[:signalp_path]
        end
        slim :results, layout: false
      end
    end

    post '/api/analyse' do
      user = session[:user].nil? ? 'npsearch' : session[:user].info['email']
      @nphmmer_results = RunNpHMMer.run(params, user)
      slim :results, layout: false
    end

    post '/api/upload' do
      dir = NpSearchHmmApp.tmp_dir + params[:qquuid]
      FileUtils.mkdir(dir) unless dir.exist?
      fname = params[:qqfilename].to_s
      fname += ".part_#{params[:qqpartindex]}" unless params[:qqtotalparts].nil?
      FileUtils.cp(params[:qqfile][:tempfile].path, dir + fname)
      { success: true }.to_json
    end

    post '/api/upload_done' do
      parts = params[:qqtotalparts].to_i - 1
      fname = params[:qqfilename]
      dir   = NpSearchHmmApp.tmp_dir + params[:qquuid]
      files = (0..parts).map { |i| dir + "#{fname}.part_#{i}" }
      system("cat #{files.join(' ')} > #{dir + fname}")
      if $CHILD_STATUS.exitstatus.zero?
        system("rm #{files.join(' ')}")
        { success: true }.to_json
      else
        { success: false }.to_json
      end
    end

    post '/api/hmm/new' do
      redirect to('auth/google_oauth2') if session[:user].nil?
      user = session[:user].info['email']
      @hmm_results = HiddenMarkovModels.add_new(params, user, request.path)
      { success: true }.to_json
      # slim :results, layout: false
    end


    # Create a share link for a result page
    post '/sh/:encoded_email/:time' do
      email = Base64.decode64(params[:encoded_email])
      analysis = NpSearchHmmApp.users_dir + email + params['time']
      share    = NpSearchHmmApp.public_dir + 'npsearch/share' + email
      FileUtils.mkdir_p(share) unless share.exist?
      FileUtils.cp_r(analysis, share)
      share_file = analysis + '.share'
      FileUtils.touch(share_file) unless share_file.exist?
    end

    # Remove a share link of a result page
    post '/rm/:encoded_email/:time' do
      email = Base64.decode64(params[:encoded_email])
      share = NpSearchHmmApp.public_dir + 'npsearch/share' + email +
              params['time']
      FileUtils.rm_rf(share) if share.exist?
      share_file = NpSearchHmmApp.users_dir + email + params['time'] + '.share'
      FileUtils.rm(share_file) if share_file.exist?
    end

    # Delete a Results Page
    post '/delete_result' do
      email = session[:user].nil? ? 'npsearch' : session[:user].info['email']
      @results_url = NpSearchHmmApp.users_dir + email + params['uuid']
      if @results_url.exist?
        FileUtils.mv(@results_url, NpSearchHmmApp.users_dir + 'archive')
      end
    end

    before '/auth/:provider/callback' do
      puts env.to_s
    end

    get '/auth/:provider/callback' do
      content_type 'text/plain'
      session[:user] = env['omniauth.auth']
      user_dir = NpSearchHmmApp.users_dir + session[:user].info['email']
      FileUtils.mkdir(user_dir) unless user_dir.exist?
      redirect request.env['omniauth.origin'] || '/analyse'
    end

    post '/auth/:provider/callback' do
      content_type :json
      session[:user] = env['omniauth.auth']
      user_dir = NpSearchHmmApp.users_dir + session[:user].info['email']
      FileUtils.mkdir(user_dir) unless user_dir.exist?
      env['omniauth.auth'].to_json
    end

    get '/logout' do
      session[:user] = nil
      redirect '/analyse'
    end

    get '/auth/failure' do
      session[:user] = nil
      redirect '/analyse'
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
      slim :"404", layout: :app_layout
    end
  end
end
