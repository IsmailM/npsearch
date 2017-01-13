# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nphmmerapp/version'

Gem::Specification.new do |spec|
  spec.name          = 'nphmmerapp'
  spec.version       = NpHMMerApp::VERSION
  spec.authors       = ['Ismail Moghul et al.']
  spec.email         = ['ismail.moghul@gmail.com']
  spec.summary       = 'A Web Application for identifying Neuropeptides' \
                       "using powerful Hidden Markov Models.\n\n For further" \
                       ' information please refer to:' \
                       ' https://github.com/wurmlab/nphmmer & ' \
                       ' https://github.com/wurmlab/nphmmerapp.'
  spec.description   = 'A Web App wrapper for NpHMMer, a program for' \
                       ' identifying neuropeptide precursors.'
  spec.homepage      = 'https://github.com/wurmlab/nphmmerapp'
  spec.license       = 'AGPL-1.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake', '~> 10.3'
  spec.add_development_dependency('rspec', '~> 2.8', '>= 2.8.0')
  spec.add_development_dependency 'rack-test', '~> 0.6'
  spec.add_development_dependency('capybara', '~> 2.4', '>= 2.4.4')
  spec.add_development_dependency 'w3c_validators', '~> 1.1'

  spec.add_dependency 'nphmmer', '~> 0.4'
  spec.add_dependency 'bio', '~> 1.4'
  spec.add_dependency 'sinatra', '~> 1.4'
  spec.add_dependency 'sinatra-cross_origin', '~> 0.3'
  spec.add_dependency 'slim', '~> 3.0'
  spec.add_dependency 'slop', '~> 3.6'
  spec.post_install_message = <<INFO

------------------------------------------------------------------------
  Thank you for Installing the NpHMMer App!

  To launch NpHMMerApp execute 'nphmmerapp' from command line.

    $ nphmmerapp [options]

  Visit https://github.com/wurmlab/nphmmerapp for more information.
------------------------------------------------------------------------

INFO
end
