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

  spec.required_ruby_version = '>= 2.7'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.2'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop', '~> 1.12'
  spec.add_development_dependency 'rubocop-rake', '~> 0.5'
  spec.add_development_dependency 'test-unit', '~> 3.4'

  spec.add_dependency 'thor', '~> 0.19.1'
end
