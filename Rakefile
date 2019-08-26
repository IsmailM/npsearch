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
  assets_dir = Pathname.new('app/public/assets').expand_path(__dir__)
  new_assets_dir = Pathname.new('app/assets/public').expand_path
  sh "rm #{new_assets_dir}/*"
  sh "rm -r #{assets_dir}"
  sh 'rake assets:clobber'
  sh 'rake assets:precompile'
  css = assets_dir.children.select { |s| s.to_s.end_with?('css') }[0]
  new_css = new_assets_dir + "npsearch-#{NpSearch::VERSION}.min.css"
  # js = assets_dir.children.select { |s| s.to_s.end_with?('js') }[0]
  # new_js = new_assets_dir + "npsearch-#{NpSearch::VERSION}.min.js"
  sh "cp #{css} #{new_css}"
  sh "cp #{js} #{new_js}"
end
