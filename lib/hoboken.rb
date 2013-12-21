require "thor"
require "thor/util"
require_relative "hoboken/version"
require_relative "hoboken/generate"

module Hoboken
  class Metrics < Thor::Group
    include Thor::Actions

    def self.source_root
      File.dirname(__FILE__)
    end

    def add_gems
      append_file("Gemfile", "\ngem \"flog\", \"~> 2.5.3\", group: :test")
      append_file("Gemfile", "\ngem \"flay\", \"~> 1.4.3\", group: :test")
      append_file("Gemfile", "\ngem \"simplecov\", \"~> 0.7.1\", require: false, group: :test")
    end

    def copy_task_templates
      empty_directory("tasks")
      template("hoboken/templates/metrics.rake.tt", "tasks/metrics.rake")
    end

    def simplecov_snippet
      insert_into_file "test/unit/test_helper.rb", before: /require "test\/unit"/ do
<<CODE

require 'simplecov'
SimpleCov.start do
  add_filter "/test/"
  coverage_dir 'tmp/coverage'
end

CODE
      end
    end

    def reminders
      say "\nGemfile updated... don't forget to 'bundle install'"
    end
  end

  class CLI < Thor
    desc "version", "Print version and quit"
    def version
      puts "Hoboken v#{Hoboken::VERSION}"
    end

    register(Generate, "generate", "generate [APP_NAME]", "Generate a new Sinatra app")
    tasks["generate"].options = Hoboken::Generate.class_options

    register(Metrics, "add:metrics", "add:metrics", "Add metrics (flog, flay, simplecov)")
  end
end
