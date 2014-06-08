require "thor"
require "thor/util"
require "fileutils"
require_relative "hoboken/version"
require_relative "hoboken/generate"
require_relative "hoboken/actions"

module Hoboken
  class Group < Thor::Group
    include Thor::Actions
    include Hoboken::Actions

    def self.source_root
      File.dirname(__FILE__)
    end
  end

  class Sequel < Thor::Group
    include Thor::Actions
    include Hoboken::Actions

    def self.source_root
      File.dirname(__FILE__)
    end

    def add_gems
      gem "sequel", version: "4.6.0"
      gem "sqlite3", version: "1.3.8", group: [:development, :test]
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
Sequel::Migrator.check_current(db, "db/migrate") if Dir.glob("db/migrate/*.rb").size > 0

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
        Sequel::Migrator.run(db, 'db/migrate') if Dir.glob("db/migrate/*.rb").size > 0
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
      gem gem_name, version: provider_version
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

  require_relative "hoboken/add_ons/metrics"
  require_relative "hoboken/add_ons/internationalization"
  require_relative "hoboken/add_ons/heroku"
  require_relative "hoboken/add_ons/sprockets"
  require_relative "hoboken/add_ons/travis"

  class CLI < Thor
    desc "version", "Print version and quit"
    def version
      puts "Hoboken v#{Hoboken::VERSION}"
    end

    register(Generate, "generate", "generate [APP_NAME]", "Generate a new Sinatra app")
    tasks["generate"].options = Hoboken::Generate.class_options

    register(AddOns::Metrics, "add:metrics", "add:metrics", "Add metrics (flog, flay, simplecov)")
    register(AddOns::Internationalization, "add:i18n", "add:i18n", "Internationalization support using sinatra-r18n")
    register(AddOns::Heroku, "add:heroku", "add:heroku", "Heroku deployment support")
    register(OmniAuth, "add:omniauth", "add:omniauth", "OmniAuth authentication (allows you to select a provider)")
    register(AddOns::Sprockets, "add:sprockets", "add:sprockets", "Rack-based asset packaging system")
    register(Sequel, "add:sequel", "add:sequel", "Database access via Sequel gem")
    register(AddOns::Travis, "add:travis", "add:travis", "Basic Travis-CI YAML config")
  end
end
