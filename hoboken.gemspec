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
  spec.add_development_dependency 'pry-byebug', '~> 3.9'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop', '~> 1.12'
  spec.add_development_dependency 'rubocop-rake', '~> 0.5'
  spec.add_development_dependency 'test-unit', '~> 3.4'
  spec.add_development_dependency 'warning', '~> 1.2'

  # These dependencies are installed by the generated projects. Including them
  # here so that:
  #
  # a) We can get Dependabot notifications for them
  # b) We can run tests for generated projects
  spec.add_development_dependency 'better_errors', '~> 2.9'
  spec.add_development_dependency 'binding_of_caller', '~> 1.0'
  spec.add_development_dependency 'bootstrap', '~> 5.0.0.beta3'
  spec.add_development_dependency 'contest', '~> 0.1'
  spec.add_development_dependency 'dotenv', '~> 2.7'
  spec.add_development_dependency 'erubi', '~> 1.10'
  spec.add_development_dependency 'flay', '~> 2.12'
  spec.add_development_dependency 'flog', '~> 4.6'
  spec.add_development_dependency 'omniauth-twitter', '~> 1.4'
  spec.add_development_dependency 'puma', '~> 5.2'
  spec.add_development_dependency 'rack_csrf', '~> 2.6'
  spec.add_development_dependency 'racksh', '~> 1.0'
  spec.add_development_dependency 'rack-test', '~> 1.1'
  spec.add_development_dependency 'rspec', '~> 3.10'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.2'
  spec.add_development_dependency 'sassc', '~> 2.4'
  spec.add_development_dependency 'sequel', '~> 5.43'
  spec.add_development_dependency 'sidekiq', '~> 6.2'
  spec.add_development_dependency 'simplecov', '~> 0.21'
  spec.add_development_dependency 'sinatra', '~> 2.1'
  spec.add_development_dependency 'sinatra-contrib', '~> 2.1'
  spec.add_development_dependency 'sinatra-flash', '~> 0.3'
  spec.add_development_dependency 'sinatra-r18n', '~> 5.0'
  spec.add_development_dependency 'sprockets', '~> 4.0'
  spec.add_development_dependency 'sqlite3', '~> 1.4'
  spec.add_development_dependency 'uglifier', '~> 4.2'
  spec.add_development_dependency 'yui-compressor', '~> 0.12'

  spec.add_dependency 'thor', '~> 1.1'
end
