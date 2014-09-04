module Hoboken
  module AddOns
    class OmniAuth < ::Hoboken::Group
      attr_reader :provider

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
  end
end
