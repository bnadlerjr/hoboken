# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hoboken/version'

Gem::Specification.new do |spec|
  spec.name          = "hoboken"
  spec.version       = Hoboken::VERSION
  spec.authors       = ["Bob Nadler"]
  spec.email         = ["bnadlerjr@gmail.com"]
  spec.description   = %q{Sinatra project generator.}
  spec.summary       = %q{Sinatra project generator.}
  spec.homepage      = "https://github.com/bnadlerjr/hoboken"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 10.1.0"

  spec.add_dependency "thor", "~> 0.18.1"
end
