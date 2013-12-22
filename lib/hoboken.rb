require "thor"
require "thor/util"
require_relative "hoboken/version"
require_relative "hoboken/generate"

module Hoboken
  class Heroku < Thor::Group
    include Thor::Actions

    def self.source_root
      File.dirname(__FILE__)
    end

    def add_gem
      append_file("Gemfile", "\ngem \"foreman\", \"~> 0.63.0\", group: :development")
    end

    def procfile
      create_file("Procfile") do
        "web: bundle exec thin start -p $PORT -e $RACK_ENV"
      end
    end

    def env_file
      create_file(".env") do
        "RACK_ENV=development\nPORT=9292"
      end
      append_to_file(".gitignore", ".env") if File.exist?(".gitignore")
    end

    def slugignore
      create_file(".slugignore") do
        "tags\n/test\n/tmp"
      end
    end

    def fix_stdout_for_logging
      prepend_file("config.ru", "$stdout.sync = true\n")
    end

    def replace_server_rake_task
      gsub_file("Rakefile", /desc.*server.*{rack_env}"\)\nend$/m) do
<<TASK
desc "Start the development server with Foreman"
task :server do
  exec("foreman start")
end
TASK
      end
    end

    def reminders
      say "\nGemfile updated... don't forget to 'bundle install'"
    end
  end

  class Internationalization < Thor::Group
    include Thor::Actions

    def self.source_root
      File.dirname(__FILE__)
    end

    def add_gem
      append_file("Gemfile", "\ngem \"sinatra-r18n\", \"~> 1.1.5\"")
      insert_into_file("app.rb", after: /require "sinatra("|\/base")/) do
        "\nrequire \"sinatra/r18n\""
      end
      insert_into_file("app.rb", after: /Sinatra::Base/) do
        "\n    register Sinatra::R18n"
      end
    end

    def translations
      empty_directory("i18n")
      template("hoboken/templates/en.yml.tt", "i18n/en.yml")
    end

    def reminders
      say "\nGemfile updated... don't forget to 'bundle install'"
    end
  end

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
    register(Internationalization, "add:i18n", "add:i18n", "Internationalization support using sinatra-r18n")
    register(Heroku, "add:heroku", "add:heroku", "Heroku deployment support")
  end
end
