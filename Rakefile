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
  `rm #{assets_dir}/js/npsearch-*.min.js`
  sh "sass -t compressed '#{assets_dir}/css/scss/style.scss'" \
     " '#{assets_dir}/css/style-#{NpSearch::VERSION}.min.css'"
  js_dir = File.join(assets_dir, 'js')
  sh "uglifyjs '#{js_dir}/dependencies/jquery.validate.min.js'" \
     " '#{js_dir}/dependencies/jquery.fine-uploader.min.js'" \
     " '#{js_dir}/dependencies/materialize.min.js'" \
     " '#{js_dir}/dependencies/npsearch.js' -m -c -o" \
     " '#{js_dir}/npsearch-#{NpSearch::VERSION}.min.js'"
end
