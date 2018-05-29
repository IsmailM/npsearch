# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'npsearch/version'

Gem::Specification.new do |spec|
  spec.name          = 'npsearch'
  spec.version       = NpSearch::VERSION
  spec.authors       = ['Ismail Moghul et al.']
  spec.email         = ['ismail.moghul@gmail.com']
  spec.summary       = 'A Tool to identify Neuropeptides. Includes a feature-' \
                       " based searching tool and a HMM-based tool. \n\n" \
                       ' For further information please refer to:' \
                       ' https://github.com/IsmailM/npsearch.'
  spec.description   = 'A Web tool for identifying neuropeptide precursors.'
  spec.homepage      = 'https://github.com/IsmailM/npsearch'
  spec.license       = 'AGPL-1.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.2.0'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'capybara', '~> 2.4', '>= 2.4.4'
  spec.add_development_dependency 'rack-test', '~> 0.6'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec', '~> 3.7'
  spec.add_development_dependency 'w3c_validators', '~> 1.1'

  spec.add_dependency 'bio', '~> 1.4'
  spec.add_dependency 'sinatra', '~> 1.4'
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
