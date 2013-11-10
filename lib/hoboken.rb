require "thor"
require_relative "hoboken/version"

module Hoboken
  class CLI < Thor::Group
    def intro
      say <<-TEXT

================================================================================
Hoboken - Sinatra Project Templates
================================================================================
TEXT
    end
  end
end
