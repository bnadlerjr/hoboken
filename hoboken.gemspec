# frozen_string_literal: true

require 'English'
require_relative 'lib/hoboken/version'

Gem::Specification.new do |spec|
  spec.name          = 'hoboken'
  spec.version       = Hoboken::VERSION
  spec.authors       = ['Bob Nadler']
  spec.email         = ['bnadlerjr@gmail.com']
  spec.description   = 'Sinatra project generator.'
  spec.summary       = 'Sinatra project generator.'
  spec.homepage      = 'https://github.com/bnadlerjr/hoboken'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.6'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.2'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop', '~> 1.12'
  spec.add_development_dependency 'rubocop-rake', '~> 0.5'
  spec.add_development_dependency 'test-unit', '~> 3.4'

  # These dependencies are installed by the generated projects. Including them
  # here so that:
  #
  # a) We can get Dependabot notifications for them
  # b) We can run tests for generated projects
  spec.add_development_dependency 'contest', '~> 0.1.3'
  spec.add_development_dependency 'dotenv', '~> 0.9.0'
  spec.add_development_dependency 'multi_json', '~> 1.15'
  spec.add_development_dependency 'puma', '~> 5.2'
  spec.add_development_dependency 'rack_csrf', '~> 2.4.0'
  spec.add_development_dependency 'sinatra', '~> 1.4.3'
  spec.add_development_dependency 'sinatra-reloader', '~> 1.0'

  spec.add_dependency 'thor', '~> 1.1'
end
