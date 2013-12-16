require "thor"
require "thor/util"
require_relative "hoboken/version"
require_relative "hoboken/generate"

module Hoboken
  class CLI < Thor
    desc "version", "Print version and quit"
    def version
      puts "Hoboken v#{Hoboken::VERSION}"
    end

    register(Generate, "generate", "generate [APP_NAME]", "Generate a new Sinatra app")
    tasks["generate"].options = Hoboken::Generate.class_options
  end
end
