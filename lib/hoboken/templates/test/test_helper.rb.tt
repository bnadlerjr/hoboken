ENV["RACK_ENV"] = "test"

require "bundler/setup"
require "test/unit"
require "contest"
require "rack/test"
require "dotenv"
require_relative "support/rack_test_assertions"
require_relative "../app"

Dotenv.load

class Test::Unit::TestCase
  # Syntactic sugar for defining a memoized helper method.
  def self.let(name, &block)
    ivar = "@#{name}"
    self.class_eval do
      define_method(name) do
        if instance_variable_defined?(ivar)
          instance_variable_get(ivar)
        else
          value = self.instance_eval(&block)
          instance_variable_set(ivar, value)
        end
      end
    end
  end
end

class Rack::Test::TestCase < Test::Unit::TestCase
  include Rack::Test::Methods
  include Rack::Test::Assertions

  private

  def app
    Sinatra::Application
  end
end
