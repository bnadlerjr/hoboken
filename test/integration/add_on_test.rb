# frozen_string_literal: true

require_relative '../test_helper'

# rubocop:disable Metrics/ClassLength
class AddOnTest < IntegrationTestCase
  # rubocop:disable Metrics/MethodLength
  def test_metrics_add_on
    run_hoboken(:generate) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:metrics")
      assert_file('Gemfile', /flog/, /flay/, /simplecov/)
      assert_file('tasks/metrics.rake')

      assert_file('test/test_helper.rb', <<~CODE
        require 'simplecov'
        SimpleCov.start do
          add_filter '/bin/'
          add_filter '/config/'
          add_filter '/test/'
          coverage_dir 'tmp/coverage'
        end

      CODE
      )

      assert_match(/no offenses detected/, execute('rubocop'))
    end
  end
  # rubocop:enable Metrics/MethodLength

  def test_internationalization_add_on_classic
    run_hoboken(:generate) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:i18n")
      assert_file('Gemfile', 'sinatra-r18n')
      assert_file('app.rb', "require 'sinatra/r18n'")
      assert_file('i18n/en.yml')
      assert_match(/no offenses detected/, execute('rubocop'))
    end
  end

  def test_internationalization_add_on_modular
    run_hoboken(:generate, type: :modular) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:i18n")
      assert_file('Gemfile', 'sinatra-r18n')
      assert_file('app.rb', "require 'sinatra/r18n'", 'register Sinatra::R18n')
      assert_file('i18n/en.yml')
      assert_match(/no offenses detected/, execute('rubocop'))
    end
  end

  def test_heroku_add_on
    run_hoboken(:generate) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:heroku")
      assert_file('.slugignore')
      assert_file('config.ru', /\$stdout.sync = true/)
      assert_match(/no offenses detected/, execute('rubocop'))
    end
  end

  # rubocop:disable Metrics/MethodLength
  def test_sprockets_add_on_classic
    run_hoboken(:generate) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:sprockets")
      assert_file('assets/styles.css')
      assert_file('assets/app.js')
      assert_file('Gemfile', 'sprockets', 'uglifier', 'yui-compressor')
      assert_file('tasks/sprockets.rake')
      assert_file('middleware/sprockets_chain.rb')
      assert_file('helpers/sprockets.rb')

      assert_file('app.rb', <<CODE
  require File.expand_path('middleware/sprockets_chain', settings.root)
  use Middleware::SprocketsChain, %r{/assets} do |env|
    %w[assets vendor].each do |f|
      env.append_path File.expand_path("../\#{f}", __FILE__)
    end
  end
CODE
      )

      assert_file('app.rb', /helpers Helpers::Sprockets/)
      assert_file('views/layout.erb', <<CODE
  <%= stylesheet_tag :styles %>

  <%= javascript_tag :app %>
CODE
      )

      assert_match(/no offenses detected/, execute('rubocop'))
    end
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def test_sprockets_add_on_modular
    run_hoboken(:generate, type: :modular) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:sprockets")
      assert_file('assets/styles.css')
      assert_file('assets/app.js')
      assert_file('Gemfile', 'sprockets', 'uglifier', 'yui-compressor')
      assert_file('tasks/sprockets.rake')
      assert_file('middleware/sprockets_chain.rb')
      assert_file('helpers/sprockets.rb')

      assert_file('app.rb', <<CODE
    configure :development do
      require File.expand_path('middleware/sprockets_chain', settings.root)
      use Middleware::SprocketsChain, %r{/assets} do |env|
        %w[assets vendor].each do |f|
          env.append_path File.expand_path("../\#{f}", __FILE__)
        end
      end
CODE
      )

      assert_file('views/layout.erb', <<CODE
  <%= stylesheet_tag :styles %>

  <%= javascript_tag :app %>
CODE
      )

      assert_match(/no offenses detected/, execute('rubocop'))
    end
  end
  # rubocop:enable Metrics/MethodLength

  def test_travis_add_on
    run_hoboken(:generate) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:travis")
      assert_file('.travis.yml', 'language: ruby')
    end
  end

  # rubocop:disable Metrics/MethodLength
  def test_sequel_add_on
    run_hoboken(:generate) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:sequel")
      assert_file('Gemfile', 'sequel', 'sqlite3')
      assert_file('tasks/sequel.rake')

      assert_file('config/db.rb')

      assert_file(
        'test/test_helper.rb',
        %r{ENV\['DATABASE_URL'\] = 'sqlite://db/test\.db'}
      )

      assert_file('test/test_helper.rb', /require 'sequel'/)
      assert_file('test/test_helper.rb', <<~CODE
        module Test
          module Database
            class TestCase < Test::Unit::TestCase
              def run(*args, &block)
                result = nil
                DB.transaction(rollback: :always) { result = super }
                result
              end
            end
          end
        end
      CODE
      )

      result = execute('rake test:all')
      assert_match(/1 tests, 3 assertions, 0 failures, 0 errors/, result)
      assert_match(/no offenses detected/, execute('rubocop'))
    end
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def test_sequel_add_on_with_rspec
    run_hoboken(:generate, test_framework: 'rspec') do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:sequel")

      assert_file(
        'spec/spec_helper.rb',
        %r{ENV\['DATABASE_URL'\] = 'sqlite://db/test\.db'}
      )

      assert_file('spec/spec_helper.rb', <<-CODE
  config.around(:example, rack: true) do |example|
    DB.transaction(rollback: :always) { example.run }
  end

  config.around(:example, database: true) do |example|
    DB.transaction(rollback: :always) { example.run }
  end

      CODE
      )

      result = execute('rake spec')
      assert_match(/3 examples, 0 failures/, result)
      assert_match(/no offenses detected/, execute('rubocop'))
    end
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def test_omniauth_add_on
    run_hoboken(:generate) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("(echo 'twitter' && echo '0.0.1') | #{bin_path} add:omniauth")
      assert_file('Gemfile', 'omniauth-twitter')
      assert_file('app.rb', /require 'omniauth-twitter'/)
      assert_file('app.rb', %r{require 'sinatra/json'})
      assert_file('app.rb', <<CODE
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

  def test_rubocop_add_on
    run_hoboken(:generate) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:rubocop")
      assert_file('Gemfile', /rubocop/, /rubocop-rake/)
      assert_file_does_not_have_content 'Gemfile', /rubocop-rspec/
      assert_file('tasks/rubocop.rake', %r{rubocop/rake_task}, /RuboCop::RakeTask\.new/)
      assert_file('Rakefile', /task ci: \['test:all', 'rubocop'\]/)

      assert_file('.rubocop.yml', '- rubocop-rake')
      assert_file('.rubocop.yml', "TargetRubyVersion: #{RUBY_VERSION}")

      assert_match(/no offenses detected/, execute('rubocop'))
    end
  end

  def test_rubocop_with_rspec_add_on
    run_hoboken(:generate, test_framework: 'rspec') do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:rubocop")
      assert_file('Gemfile', /rubocop/, /rubocop-rspec/)
      assert_file('tasks/rubocop.rake', %r{rubocop/rake_task}, /RuboCop::RakeTask\.new/)
      assert_file('Rakefile', /task ci: .*spec rubocop/)

      assert_file('.rubocop.yml', '- rubocop-rspec')

      assert_match(/no offenses detected/, execute('rubocop'))
    end
  end

  def test_github_action_add_on
    run_hoboken(:generate) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:github_action")
      assert_file('.github/workflows/ruby.yml')
      assert_match(/no offenses detected/, execute('rubocop'))
    end
  end
end
# rubocop:enable Metrics/ClassLength
