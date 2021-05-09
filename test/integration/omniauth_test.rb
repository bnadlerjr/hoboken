# frozen_string_literal: true

require_relative '../test_helper'

class OmniauthTest < IntegrationTestCase
  # rubocop:disable Metrics/MethodLength
  def test_omniauth_add_on
    run_hoboken(:generate) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("(echo 'twitter' && echo '0.0.1') | #{bin_path} add:omniauth")
      assert_file('Gemfile', 'omniauth-twitter')
      assert_file('app.rb', /require 'omniauth-twitter'/)
      assert_file('app.rb', %r{require 'sinatra/json'})
      assert_file('config/environment.rb', <<CODE
  use OmniAuth::Builder do
    provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
  end
CODE
      )

      assert_file('app.rb', <<~CODE
        get '/login' do
          '<a href="/auth/twitter">Login</a>'
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
      )

      assert_match(/no offenses detected/, execute('rubocop'))
    end
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def test_omniauth_add_on_tests
    run_hoboken(:generate) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("(echo 'twitter' && echo '0.0.1') | #{bin_path} add:omniauth")
      assert_file('test/unit/app_test.rb', <<-CODE
  setup do
    OmniAuth.config.test_mode = true
  end

  test 'GET /login' do
    get '/login'
    assert_equal('<a href="/auth/twitter">Login</a>', last_response.body)
  end

  test 'GET /auth/twitter/callback' do
    auth_hash = {
      provider: 'twitter',
      uid: '123545',
      info: {
        name: 'John Doe'
      }
    }

    OmniAuth.config.mock_auth[:twitter] = auth_hash
    get '/auth/twitter/callback'
    assert_equal(MultiJson.encode(auth_hash), last_response.body)
  end

  test 'GET /auth/failure' do
    OmniAuth.config.mock_auth[:twitter] = :invalid_credentials
    get '/auth/failure'
    assert_response :not_authorized
  end

      CODE
      )
    end
  end
  # rubocop:enable Metrics/MethodLength

  def test_omniauth_add_on_tests_pass
    run_hoboken(:generate) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("(echo 'twitter' && echo '0.0.1') | #{bin_path} add:omniauth")
      execute('bundle install')
      result = execute('rake test:all')
      assert_match(/4 tests, 6 assertions, 0 failures, 0 errors/, result)
    end
  end

  # rubocop:disable Metrics/MethodLength
  def test_omniauth_add_on_specs
    run_hoboken(:generate, test_framework: 'rspec') do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("(echo 'twitter' && echo '0.0.1') | #{bin_path} add:omniauth")
      assert_file(
        'spec/app_spec.rb',
        <<~CODE
          # rubocop:disable RSpec/DescribeClass
          RSpec.describe 'omniauth', rack: true do
            before(:each) { OmniAuth.config.test_mode = true }

            describe 'GET /login' do
              before(:each) { get '/login' }

              it { expect(last_response).to have_http_status(:ok) }
              it { expect(last_response).to have_content_type(:html) }

              it 'renders a template with a login link' do
                twitter_link = '<a href="/auth/twitter">Login</a>'
                expect(last_response.body).to include(twitter_link)
              end
            end

            describe 'GET /auth/twitter/callback' do
              let(:auth_hash) do
                {
                  provider: 'twitter',
                  uid: '123545',
                  info: {
                    name: 'John Doe'
                  }
                }
              end

              before(:each) do
                OmniAuth.config.mock_auth[:twitter] = auth_hash
                get '/auth/twitter/callback'
              end

              it { expect(last_response).to have_http_status(:ok) }
              it { expect(last_response).to have_content_type(:json) }

              it 'renders the auth hash result' do
                expect(last_response.body).to eq(JSON.generate(auth_hash))
              end
            end

            describe 'GET /auth/failure' do
              before(:each) do
                OmniAuth.config.mock_auth[:twitter] = :invalid_credentials
                get '/auth/failure'
              end

              it { expect(last_response).to have_http_status(:not_authorized) }
            end
          end
          # rubocop:enable RSpec/DescribeClass
      CODE
      )
    end
  end
  # rubocop:enable Metrics/MethodLength

  def test_omniauth_add_on_specs_pass
    run_hoboken(:generate, test_framework: 'rspec') do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("(echo 'twitter' && echo '0.0.1') | #{bin_path} add:omniauth")
      execute('bundle install')
      result = execute('rake spec')
      assert_match(/10 examples, 0 failures/, result)
    end
  end
end
