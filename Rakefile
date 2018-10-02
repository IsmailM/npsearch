# frozen_string_literal: true

require 'sinatra/asset_pipeline/task'
require_relative './lib/npsearch_hmm_app'

Sinatra::AssetPipeline::Task.define! NpSearchHmmApp::Routes

task default: [:build]

desc 'Builds and installs'
task install: [:build] do
  require_relative 'lib/npsearch/version'
  gem = File.join(__dir__, "npsearch-#{NpSearch::VERSION}.gem")
  sh "gem install #{gem}"
end

desc 'Runs tests and builds gem (default)'
task build: [:test] do
  gemspec = File.join(__dir__, 'npsearch.gemspec')
  sh "gem build #{gemspec}"
end

task test: :spec
require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :assets do
  require_relative 'lib/npsearch/version'
  assets_dir = File.join(__dir__, 'public/assets')
  `rm #{assets_dir}/css/style-*.min.css`
  `rm #{assets_dir}/css/style-*.min.css.map`
  `rm #{assets_dir}/js/npsearch-*.min.js`
  `rm #{assets_dir}/js/npsearch-*.min.js.map`
  sh "sass -t compressed '#{assets_dir}/css/scss/style.scss'" \
     " '#{assets_dir}/css/style-#{NpSearch::VERSION}.min.css'"
  sh "uglifyjs '#{assets_dir}/js/dependencies/jquery.validate.min.js'" \
     " '#{assets_dir}/js/dependencies/jquery.fine-uploader.min.js'" \
     " '#{assets_dir}/js/dependencies/materialize.min.js'" \
     " '#{assets_dir}/js/dependencies/npsearch.js' -m -c -o" \
     " '#{assets_dir}/js/npsearch-#{NpSearch::VERSION}.min.js'"
end
