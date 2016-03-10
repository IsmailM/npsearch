require 'bundler/gem_tasks'
require 'rspec/core'
require 'rspec/core/rake_task'

task default: [:build]

desc 'Builds and installs'
task install: [:build] do
  require_relative 'lib/genevalidatorapp/version'
  sh "gem install ./genevalidatorapp-#{GeneValidatorApp::VERSION}.gem"
end

desc 'Runs tests and builds gem (default)'
task build: [:test] do
  sh 'gem build genevalidatorapp.gemspec'
end

task test: :spec
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :assets do
  require_relative 'lib/nphmmerapp/version'
  `rm ./public/assets/css/style-*.min.css`
  `rm ./public/assets/js/nphmmer-*.min.js`
  sh 'cleancss --s0 -s --skip-rebase -o' \
     " './public/assets/css/style-#{NpHMMerApp::VERSION}.min.css'" \
     " './public/assets/css/style.css'"
  sh "uglifyjs './public/assets/js/jquery.min.js'" \
     " './public/assets/js/jquery.validate.min.js'" \
     " './public/assets/js/fine-uploader.min.js'" \
     " './public/assets/js/materialize.min.js'" \
     " './public/assets/js/nphmmer.js' -m -c -o" \
     " './public/assets/js/nphmmer-#{NpHMMerApp::VERSION}.min.js'"
end
