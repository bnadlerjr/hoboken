# frozen_string_literal: true

require_relative '../test_helper'

# rubocop:disable Metrics/ClassLength
class AddOnTest < IntegrationTestCase
  def test_metrics_add_on
    run_hoboken(:generate) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:metrics")
      assert_file('Gemfile', /flog/, /flay/, /simplecov/)
      assert_file('tasks/metrics.rake')
      assert_file('test/test_helper.rb', <<~CODE
        require 'simplecov'
        SimpleCov.start do
          add_filter '/test/'
          coverage_dir 'tmp/coverage'
        end

      CODE
      )
    end
  end

  def test_internationalization_add_on_classic
    run_hoboken(:generate) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:i18n")
      assert_file('Gemfile', 'sinatra-r18n')
      assert_file('app.rb', "require 'sinatra/r18n'")
      assert_file('i18n/en.yml')
    end
  end

  def test_internationalization_add_on_modular
    run_hoboken(:generate, type: :modular) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:i18n")
      assert_file('Gemfile', 'sinatra-r18n')
      assert_file('app.rb', "require 'sinatra/r18n'", 'register Sinatra::R18n')
      assert_file('i18n/en.yml')
    end
  end

  def test_heroku_add_on
    run_hoboken(:generate) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:heroku")
      assert_file('Gemfile', 'foreman')
      assert_file('Procfile')
      assert_file('.slugignore')
      assert_file('config.ru', /\$stdout.sync = true/)
      assert_file('Rakefile', /exec\('foreman start'\)/)
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
      assert_file('app.rb', <<~CODE
        if development?
          require 'sinatra/reloader'

          require File.expand_path('middleware/sprockets_chain', settings.root)
          use Middleware::SprocketsChain, %r{/assets} do |env|
            %w(assets vendor).each do |f|
              env.append_path File.expand_path("../\#{f}", __FILE__)
            end
          end
        end

        helpers Helpers::Sprockets
      CODE
      )
      assert_file('views/layout.erb', <<CODE
  <%= stylesheet_tag :styles %>

  <%= javascript_tag :app %>
CODE
      )
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
        %w(assets vendor).each do |f|
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

      assert_file('config.ru', /require 'logger'/)
      assert_file('config.ru', /require 'sequel'/)
      assert_file('config.ru', <<~CODE
        db = Sequel.connect(ENV['DATABASE_URL'], loggers: [Logger.new($stdout)])
        Sequel.extension :migration
        Sequel::Migrator.check_current(db, 'db/migrate') if Dir.glob('db/migrate/*.rb').size > 0

        app = Sinatra::Application
        app.set :database, db
        run app
      CODE
      )

      assert_file('test/test_helper.rb', /require 'sequel'/)
      assert_file('test/test_helper.rb', <<~CODE
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
                Sequel::Migrator.run(db, 'db/migrate') if Dir.glob('db/migrate/*.rb').size > 0
              end
            end
          end
        end
      CODE
      )
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
      assert_file('app.rb', <<~CODE
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
          MultiJson.encode(request.env['omniauth.auth'])
        end

        get '/auth/failure' do
          # TODO: Insert real error handling logic...
          halt 401, params[:message]
        end
      CODE
      )
    end

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
      "provider" => "twitter",
      "uid" => "123545",
      "info" => {
        "name" => "John Doe"
      }
    }

    OmniAuth.config.mock_auth[:twitter] = auth_hash
    get '/auth/fitbit/callback'
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
  # rubocop:enable Metrics/MethodLength
end
# rubocop:enable Metrics/ClassLength
