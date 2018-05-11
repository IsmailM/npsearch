task default: [:build]

desc 'Builds and installs'
task install: [:build] do
  require_relative 'lib/npsearch/version'
  sh "gem install ./npsearch-#{NpSearch::VERSION}.gem"
end

desc 'Runs tests and builds gem (default)'
task build: [:test] do
  sh 'gem build npsearch.gemspec'
end

task test: :spec
require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :assets do
  require_relative 'lib/npsearch/version'
  `rm ./public/assets/css/style-*.min.css`
  `rm ./public/assets/js/npsearch-*.min.js`
  sh 'cleancss --s0 -s --skip-rebase -o' \
     " './public/assets/css/style-#{NpSearch::VERSION}.min.css'" \
     " './public/assets/css/style.css'"
  sh "uglifyjs './public/assets/js/jquery.min.js'" \
     " './public/assets/js/jquery.validate.min.js'" \
     " './public/assets/js/fine-uploader.min.js'" \
     " './public/assets/js/materialize.min.js'" \
     " './public/assets/js/npsearch.js' -m -c -o" \
     " './public/assets/js/npsearch-#{NpSearch::VERSION}.min.js'"
end
