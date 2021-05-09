# frozen_string_literal: true

module Hoboken
  module AddOns
    # OmniAuth authentication (allows you to select a provider).
    #
    class OmniAuth < ::Hoboken::Group
      attr_reader :provider

      def add_gem
        @provider = ask('Specify a provider (i.e. twitter, facebook. etc.): ').downcase
        provider_version = ask('Specify provider version: ')
        gem gem_name, version: provider_version
      end

      def setup_middleware
        insert_into_file('app.rb', after: %r{require 'sinatra('|/base')}) do
          "\nrequire '#{gem_name}'\nrequire 'sinatra/json'\n"
        end

        snippet = <<~CODE
          use OmniAuth::Builder do
            provider :#{provider}, ENV['#{provider.upcase}_KEY'], ENV['#{provider.upcase}_SECRET']
          end
        CODE

        indentation = classic? ? 2 : 6
        location = /use Rack::Session::Cookie.+\n/
        insert_into_file('config/environment.rb', after: location) do
          "\n#{indent(snippet, indentation)}\n"
        end
      end

      # rubocop:disable Metrics/MethodLength
      def add_routes
        routes = <<~CODE

          get '/login' do
            '<a href="/auth/#{provider}">Login</a>'
          end

          get '/auth/:provider/callback' do
            # TODO: Insert real authentication logic...
            json request.env['omniauth.auth']
          end

          get '/auth/failure' do
            # TODO: Insert real error handling logic...
            halt 401, params[:message]
          end
        CODE

        if classic?
          append_file('app.rb', routes)
        else
          inject_into_class('app.rb', 'App') { indent(routes, 4) }
        end
      end
      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/MethodLength
      def add_tests
        return if rspec?

        inject_into_class('test/unit/app_test.rb', 'AppTest') do
          <<-CODE
  setup do
    OmniAuth.config.test_mode = true
  end

  test 'GET /login' do
    get '/login'
    assert_equal('<a href="/auth/#{provider}">Login</a>', last_response.body)
  end

  test 'GET /auth/#{provider}/callback' do
    auth_hash = {
      provider: '#{provider}',
      uid: '123545',
      info: {
        name: 'John Doe'
      }
    }

    OmniAuth.config.mock_auth[:#{provider}] = auth_hash
    get '/auth/#{provider}/callback'
    assert_equal(MultiJson.encode(auth_hash), last_response.body)
  end

  test 'GET /auth/failure' do
    OmniAuth.config.mock_auth[:#{provider}] = :invalid_credentials
    get '/auth/failure'
    assert_response :not_authorized
  end

          CODE
        end
      end
      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/MethodLength
      def add_specs
        return unless rspec?

        append_file('spec/app_spec.rb') do
          <<~CODE

            # rubocop:disable RSpec/DescribeClass
            RSpec.describe 'omniauth', rack: true do
              before(:each) { OmniAuth.config.test_mode = true }

              describe 'GET /login' do
                before(:each) { get '/login' }

                it { expect(last_response).to have_http_status(:ok) }
                it { expect(last_response).to have_content_type(:html) }

                it 'renders a template with a login link' do
                  #{provider}_link = '<a href="/auth/#{provider}">Login</a>'
                  expect(last_response.body).to include(#{provider}_link)
                end
              end

              describe 'GET /auth/#{provider}/callback' do
                let(:auth_hash) do
                  {
                    provider: '#{provider}',
                    uid: '123545',
                    info: {
                      name: 'John Doe'
                    }
                  }
                end

                before(:each) do
                  OmniAuth.config.mock_auth[:#{provider}] = auth_hash
                  get '/auth/#{provider}/callback'
                end

                it { expect(last_response).to have_http_status(:ok) }
                it { expect(last_response).to have_content_type(:json) }

                it 'renders the auth hash result' do
                  expect(last_response.body).to eq(JSON.generate(auth_hash))
                end
              end

              describe 'GET /auth/failure' do
                before(:each) do
                  OmniAuth.config.mock_auth[:#{provider}] = :invalid_credentials
                  get '/auth/failure'
                end

                it { expect(last_response).to have_http_status(:not_authorized) }
              end
            end
            # rubocop:enable RSpec/DescribeClass
          CODE
        end
      end
      # rubocop:enable Metrics/MethodLength

      def reminders
        say "\nGemfile updated... don't forget to 'bundle install'"
      end

      private

      def gem_name
        "omniauth-#{provider}"
      end
    end
  end
end
