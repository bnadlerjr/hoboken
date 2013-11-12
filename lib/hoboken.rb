require "thor"
require "thor/util"
require_relative "hoboken/version"

module Hoboken
  class Generate < Thor::Group
    include Thor::Actions

    argument :name

    def self.source_root
      File.dirname(__FILE__)
    end

    def app_folder
      empty_directory(snake_name)
      apply_template("app.rb.tt",    "app.rb")
      apply_template("Gemfile.tt",   "Gemfile")
      apply_template("config.ru.tt", "config.ru")
      apply_template("README.md.tt", "README.md")
    end

    def view_folder
      empty_directory("#{snake_name}/views")
      apply_template("views/layout.erb.tt", "views/layout.erb")
      apply_template("views/index.erb.tt", "views/index.erb")
    end

    def public_folder
      inside snake_name do
        empty_directory("public")
        %w(css img js).each { |f| empty_directory("public/#{f}") }
      end
    end

    def directions
      say "\nSuccessfully created #{name}. Don't forget to `bundle install`"
    end

    private

    def snake_name
      Thor::Util.snake_case(name)
    end

    def author
      `git config user.name`.chomp
    end

    def apply_template(src, dest)
      template("hoboken/templates/#{src}", "#{snake_name}/#{dest}")
    end
  end

  class CLI < Thor
    desc "version", "Print version and quit"
    def version
      puts "Hoboken v#{Hoboken::VERSION}"
    end

    register(Generate, "generate", "generate", "Generate a new Sinatra app")
  end
end
