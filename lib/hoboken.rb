require "thor"
require "thor/util"
require "fileutils"
require_relative "hoboken/version"
require_relative "hoboken/generate"
require_relative "hoboken/actions"

module Hoboken
  class Sequel < Thor::Group
    include Thor::Actions
    include Hoboken::Actions

    def self.source_root
      File.dirname(__FILE__)
    end

    def add_gems
      gem "sequel", "4.6.0"
      gem "sqlite3", "1.3.8", group: [:development, :test]
    end

    def setup_directories
      empty_directory("db/migrate")
      empty_directory("tasks")
    end

    def copy_rake_task
      copy_file("hoboken/templates/sequel.rake", "tasks/sequel.rake")
    end

    def setup_database_connection_in_rackup_file
      insert_into_file("config.ru", after: /require "bundler\/setup"/) do
        "\nrequire \"logger\"\nrequire \"sequel\""
      end

      app_name = File.open("config.ru").grep(/run.+/).first.chomp.gsub("run ", "")

      gsub_file("config.ru", /run #{app_name}/) do
<<CODE

db = Sequel.connect(ENV["DATABASE_URL"], loggers: [Logger.new($stdout)])
Sequel.extension :migration
Sequel::Migrator.check_current(db, "db/migrate") if File.exist?("db/migrate/*.rb")

app = #{app_name}
app.set :database, db
run app
CODE
      end
    end

    def add_database_test_helper_class
      insert_into_file("test/test_helper.rb", after: /require "test\/unit"/) do
        "\nrequire \"sequel\""
      end

      append_file("test/test_helper.rb") do
<<CODE

module Test::Database
  class TestCase < Test::Unit::TestCase
    def run(*args, &block)
      result = nil
      database.transaction(rollback: :always) { result = super }
      result
    end

    private

    def database
      @database ||= Sequel.sqlite.tap do |db|
        Sequel.extension :migration
        Sequel::Migrator.run(db, 'db/migrate')
      end
    end
  end
end
CODE
      end
    end

    def reminders
      say "\nGemfile updated... don't forget to 'bundle install'"
      say <<TEXT

Notes:
* The sqlite3 gem has been installed for dev and test environments only. You will need to specify a gem to use for production.
* You will need to specify an environment variable 'DATABASE_URL' (either add it to .env or export it)
TEXT
    end
  end

  class OmniAuth < Thor::Group
    include Thor::Actions
    include Hoboken::Actions

    attr_reader :provider

    def self.source_root
      File.dirname(__FILE__)
    end

    def add_gem
      @provider = ask("Specify a provider (i.e. twitter, facebook. etc.): ").downcase
      provider_version = ask("Specify provider version: ")
      gem gem_name, provider_version
    end

    def setup_middleware
      insert_into_file("app.rb", after: /require "sinatra("|\/base")/) do
        "\nrequire \"#{gem_name}\""
      end

      snippet = <<-CODE

use OmniAuth::Builder do
  provider :#{provider}, ENV["#{provider.upcase}_KEY"], ENV["#{provider.upcase}_SECRET"]
end

CODE

      text = modular? ? indent(snippet, 4) : snippet
      insert_into_file("app.rb", after: /use Rack::Session::Cookie.+\n/) { text }
    end

    def add_routes
      routes = <<-CODE


get "/login" do
  '<a href="/auth/#{provider}">Login</a>'
end

get "/auth/:provider/callback" do
  # TODO: Insert real authentication logic...
  MultiJson.encode(request.env['omniauth.auth'])
end

get "/auth/failure" do
  # TODO: Insert real error handling logic...
  halt 401, params[:message]
end
CODE

      if modular?
        insert_into_file("app.rb", after: /get.+?end$/m) { indent(routes, 4) }
      else
        append_file("app.rb", routes)
      end
    end

    def add_tests
      inject_into_class("test/unit/app_test.rb", "AppTest") do
<<-CODE
  setup do
    OmniAuth.config.test_mode = true
  end

  test "GET /login" do
    get "/login"
    assert_equal('<a href="/auth/#{provider}">Login</a>', last_response.body)
  end

  test "GET /auth/#{provider}/callback" do
    auth_hash = {
      "provider" => "#{provider}",
      "uid" => "123545",
      "info" => {
        "name" => "John Doe"
      }
    }

    OmniAuth.config.mock_auth[:#{provider}] = auth_hash
    get "/auth/fitbit/callback"
    assert_equal(MultiJson.encode(auth_hash), last_response.body)
  end

  test "GET /auth/failure" do
    OmniAuth.config.mock_auth[:#{provider}] = :invalid_credentials
    get "/auth/failure"
    assert_response :not_authorized
  end

CODE
      end
    end

    def reminders
      say "\nGemfile updated... don't forget to 'bundle install'"
    end

    private

    def gem_name
      "omniauth-#{provider}"
    end

    def modular?
      @modular ||= File.readlines("app.rb").grep(/Sinatra::Base/).any?
    end
  end

  class Sprockets < Thor::Group
    include Thor::Actions
    include Hoboken::Actions

    def self.source_root
      File.dirname(__FILE__)
    end

    def create_assets_folder
      empty_directory("assets")
      FileUtils.cp("public/css/styles.css", "assets/styles.css")
      FileUtils.cp("public/js/app.js", "assets/app.js")
    end

    def add_gems
      gem "sprockets", "2.10.0", group: :assets
      gem "uglifier", "2.1.1", group: :assets
      gem "yui-compressor", "0.9.6", group: :assets
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
    include Hoboken::Actions

    def self.source_root
      File.dirname(__FILE__)
    end

    def add_gem
      gem "foreman", "0.63.0", group: :development
    end

    def procfile
      create_file("Procfile") do
        "web: bundle exec thin start -p $PORT -e $RACK_ENV"
      end
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
    include Hoboken::Actions

    def self.source_root
      File.dirname(__FILE__)
    end

    def add_gem
      gem "sinatra-r18n", "1.1.5"
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
    include Hoboken::Actions

    def self.source_root
      File.dirname(__FILE__)
    end

    def add_gems
      gem "flog", "2.5.3", group: :test
      gem "flay", "1.4.3", group: :test
      gem "simplecov", "0.7.1", require: false, group: :test
    end

    def copy_task_templates
      empty_directory("tasks")
      template("hoboken/templates/metrics.rake.tt", "tasks/metrics.rake")
    end

    def simplecov_snippet
      insert_into_file "test/test_helper.rb", before: /require "test\/unit"/ do
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
    register(OmniAuth, "add:omniauth", "add:omniauth", "OmniAuth authentication (allows you to select a provider)")
    register(Sprockets, "add:sprockets", "add:sprockets", "Rack-based asset packaging system")
    register(Sequel, "add:sequel", "add:sequel", "Database access via Sequel gem")
  end
end
