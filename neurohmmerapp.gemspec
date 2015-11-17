# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'neurohmmerapp/version'

Gem::Specification.new do |spec|
  spec.name          = 'neurohmmerapp'
  spec.version       = NeuroHmmerApp::VERSION
  spec.authors       = ['Ismail Moghul', 'Yannick Wurm']
  spec.email         = 'y.wurm@qmul.ac.uk'
  spec.summary       = 'A Web App wrapper for NeuroHmmer.'
  spec.description   = 'A Web App wrapper for NeuroHmmer, a program for' \
                       ' validating gene predictions.'
  spec.homepage      = 'https://github.com/wurmlab/neurohmmerapp'
  spec.license       = 'AGPL'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake', '~>10.3'
  spec.add_development_dependency('rspec', '~> 2.8', '>= 2.8.0')
  spec.add_development_dependency 'rack-test', '~> 0.6'
  spec.add_development_dependency('capybara', '~> 2.4', '>= 2.4.4')
  spec.add_development_dependency 'w3c_validators', '~>1.1'

  spec.add_dependency 'neurohmmer', '~>0.1'
  spec.add_dependency 'bio', '~>1.4'
  spec.add_dependency 'sinatra', '~>1.4'
  spec.add_dependency 'sinatra-cross_origin', '~> 0.3'
  spec.add_dependency 'slim', '~>3.0'
  spec.add_dependency 'slop', '~>3.6'
  spec.post_install_message = <<INFO

------------------------------------------------------------------------
  Thank you for Installing the NeuroHmmer App!

  To launch NeuroHmmerApp execute 'neurohmmerapp' from command line.

    $ neurohmmerapp [options]

  Visit https://github.com/wurmlab/neurohmmerapp for more information.
------------------------------------------------------------------------

INFO
end
