require "thor"
require_relative "hoboken/version"

module Hoboken
  class CLI < Thor
    desc "version", "Print version and quit"
    def version
      puts "Hoboken v#{Hoboken::VERSION}"
    end
  end
end
