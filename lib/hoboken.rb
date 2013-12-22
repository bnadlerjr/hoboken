require "thor"
require "thor/util"
require "fileutils"
require_relative "hoboken/version"
require_relative "hoboken/generate"

module Hoboken
  class Sprockets < Thor::Group
    include Thor::Actions

    def self.source_root
      File.dirname(__FILE__)
    end

    def create_assets_folder
      empty_directory("assets")
      FileUtils.cp("public/css/styles.css", "assets/styles.css")
      FileUtils.cp("public/js/app.js", "assets/app.js")
    end

    def add_gems
      append_file("Gemfile", "\ngem \"sprockets\", \"~> 2.10.0\", group: :assets")
      append_file("Gemfile", "\ngem \"uglifier\", \"~> 2.1.1\", group: :assets")
      append_file("Gemfile", "\ngem \"yui-compressor\", \"~> 0.9.6\", group: :assets")
    end

    def copy_sprockets_helpers
      copy_file("hoboken/templates/sprockets.rake", "tasks/sprockets.rake")
      copy_file("hoboken/templates/sprockets_chain.rb", "middleware/sprockets_chain.rb")
      copy_file("hoboken/templates/sprockets_helper.rb", "helpers/sprockets.rb")
    end

    def update_app
      insert_into_file("app.rb", after: /configure :development do\n/) do
<<CODE
      require File.expand_path('middleware/sprockets_chain', settings.root)
      use Middleware::SprocketsChain, %r{/assets} do |env|
        %w(assets vendor).each do |f|
          env.append_path File.expand_path("../\#{f}", __FILE__)
        end
      end

CODE
      end

      insert_into_file("app.rb", after: /set :root, File.dirname\(__FILE__\)\n/) do
        "    helpers Helpers::Sprockets"
      end

      gsub_file("app.rb", /require "sinatra\/reloader" if development\?/) do
<<CODE
if development?
  require "sinatra/reloader"

  require File.expand_path('middleware/sprockets_chain', settings.root)
  use Middleware::SprocketsChain, %r{/assets} do |env|
    %w(assets vendor).each do |f|
      env.append_path File.expand_path("../\#{f}", __FILE__)
    end
  end
end

helpers Helpers::Sprockets
CODE
      end
    end

    def adjust_link_tags
      insert_into_file("views/layout.erb", before: /<\/head>/) do
<<HTML
  <%= stylesheet_tag :styles %>

  <%= javascript_tag :app %>
HTML
      end

      gsub_file("views/layout.erb", /<link rel="stylesheet" type="text\/css" href="css\/styles.css">/, "")
      gsub_file("views/layout.erb", /<script type="text\/javascript" src="js\/app.js"><\/script>/, "")
    end

    def directions
      text = <<TEXT

Run `bundle install` to get the sprockets gem and its
dependencies.

Running the server in development mode will serve css
and js files from /assets. In order to serve assets in
production, you must run `rake assets:precompile`. Read
the important note below before running this rake task.
TEXT

      important = <<TEXT

Important Note:
Any css or js files from the /public folder have been copied
to /assets, the original files remain intact in /public, but
will be replaced the first time you run `rake assets:precompile`.
You may want to backup those files if they are not under source
control before running the Rake command.
TEXT

      say text
      say important, :red
    end
  end

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
    register(Sprockets, "add:sprockets", "add:sprockets", "Rack-based asset packaging system")
  end
end
