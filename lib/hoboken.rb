require "thor"
require "thor/util"
require_relative "hoboken/version"

module Hoboken
  class Generate < Thor::Group
    include Thor::Actions

    argument :name
    class_option :ruby_version,
                 type: :string,
                 desc: "Ruby version for Gemfile",
                 default: RUBY_VERSION

    def self.source_root
      File.dirname(__FILE__)
    end

    def app_folder
      empty_directory(snake_name)
      apply_template("app.rb.tt",      "app.rb")
      apply_template("Gemfile.erb.tt", "Gemfile")
      apply_template("config.ru.tt",   "config.ru")
      apply_template("README.md.tt",   "README.md")
      apply_template("Rakefile.tt",    "Rakefile")
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

    def test_folder
      empty_directory("#{snake_name}/test/unit")
      empty_directory("#{snake_name}/test/support")
      apply_template("test/unit/test_helper.rb.tt", "test/unit/test_helper.rb")
      apply_template("test/unit/app_test.rb.tt", "test/unit/app_test.rb")
      apply_template("test/support/rack_test_assertions.rb.tt", "test/support/rack_test_assertions.rb")
    end

    def directions
      say "\nSuccessfully created #{name}. Don't forget to `bundle install`"
    end

    private

    def snake_name
      Thor::Util.snake_case(name)
    end

    def titleized_name
      snake_name.split("_").map(&:capitalize).join(" ")
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

    register(Generate, "generate", "generate [APP_NAME]", "Generate a new Sinatra app")
    tasks["generate"].options = Hoboken::Generate.class_options
  end
end
