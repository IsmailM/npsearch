require 'rack/test'
require 'rspec'
require 'capybara/rspec'
require 'w3c_validators'

require 'nphmmerapp'

# Basic unit tests for HTTP / Rack interface.
module NpHMMerApp
  include W3CValidators
  describe 'Routes' do
    ENV['RACK_ENV'] = 'production'
    include Rack::Test::Methods

    let 'root' do
      NpHMMerApp.root
    end

    let 'empty_config' do
      File.join(root, 'spec', 'empty_config.yml')
    end

    let 'database_dir' do
      File.join(root, 'spec', 'database')
    end

    before :each do
      NpHMMerApp.init(config_file: empty_config,
                      database_dir: database_dir)

      nps      = %w(all)
      sequence = 'AGCTAGCTAGCT'

      @params   = {
        'neuropeptides' => nps,
        'seq'           => sequence
      }
    end

    let 'app' do
      NpHMMerApp
    end

    it 'should start the app' do
      get '/'
      last_response.ok?.should == true
    end

    it 'returns Bad Request (400) if no sequence is provided' do
      @params.delete('seq')
      post '/', @params
      last_response.status.should == 400
    end

    it 'returns Bad Request (400) if no neuropeptides is provided' do
      @params.delete('neuropeptides')
      post '/', @params
      last_response.status.should == 400
    end

    it 'validate the html' do
      get '/'
      html = last_response.body

      validator = MarkupValidator.new
      results = validator.validate_text(html)

      results.errors.each { |err| puts err.to_s } if results.errors.length > 0
      results.errors.length.should == 0
    end
  end
end
