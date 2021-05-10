# frozen_string_literal: true

require_relative '../test_helper'

class SidekiqTest < IntegrationTestCase
  # rubocop:disable Metrics/MethodLength
  def test_sidekiq_add_on_with_classic_and_test_unit
    run_hoboken(:generate) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:sidekiq")
      assert_file('Gemfile', 'sidekiq')
      assert_file('config.ru', "require 'sidekiq/web'")

      assert_file('config.ru', <<~CODE
        if 'production' == ENV.fetch('RACK_ENV', 'production')
          Sidekiq::Web.use Rack::Auth::Basic do |username, password|
            [username, password] == [ENV['SIDEKIQ_USERNAME'], ENV['SIDEKIQ_PASSWORD']]
          end
        end

        Sidekiq::Web.use Rack::Session::Cookie, secret: ENV['SESSION_SECRET']
        run Rack::URLMap.new('/' => Sinatra::Application, '/sidekiq' => Sidekiq::Web)
      CODE
      )

      assert_file('config/sidekiq.rb')
      assert_file('workers/example_worker.rb')
      assert_file('test/unit/example_worker_test.rb')
    end
  end
  # rubocop:enable Metrics/MethodLength

  def test_sidekiq_add_on_with_classic_and_rspec
    run_hoboken(:generate, test_framework: 'rspec') do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:sidekiq")
      assert_file('workers/example_worker.rb')
      assert_file('spec/spec_helper.rb', <<CODE
  config.before(:each, sidekiq: true) do
    Sidekiq::Worker.clear_all
  end
CODE
      )

      assert_file('spec/example_worker_spec.rb')
    end
  end

  # rubocop:disable Metrics/MethodLength
  def test_sidekiq_add_on_with_modular_and_test_unit
    run_hoboken(:generate, type: :modular) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:sidekiq")
      assert_file('Gemfile', 'sidekiq')
      assert_file('config.ru', "require 'sidekiq/web'")

      assert_file('config.ru', <<~CODE
        if 'production' == ENV.fetch('RACK_ENV', 'production')
          Sidekiq::Web.use Rack::Auth::Basic do |username, password|
            [username, password] == [ENV['SIDEKIQ_USERNAME'], ENV['SIDEKIQ_PASSWORD']]
          end
        end

        Sidekiq::Web.use Rack::Session::Cookie, secret: ENV['SESSION_SECRET']
        run Rack::URLMap.new('/' => Sample::App, '/sidekiq' => Sidekiq::Web)
      CODE
      )

      assert_file('config/sidekiq.rb')
      assert_file('workers/example_worker.rb')
      assert_file('test/unit/example_worker_test.rb')
    end
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def test_sidekiq_add_on_with_modular_and_rspec
    run_hoboken(:generate, type: :modular, test_framework: 'rspec') do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:sidekiq")
      assert_file('workers/example_worker.rb')
      assert_file('spec/spec_helper.rb', <<CODE
  config.before(:each, sidekiq: true) do
    Sidekiq::Worker.clear_all
  end
CODE
      )

      assert_file('config.ru', <<~CODE
        if 'production' == ENV.fetch('RACK_ENV', 'production')
          Sidekiq::Web.use Rack::Auth::Basic do |username, password|
            [username, password] == [ENV['SIDEKIQ_USERNAME'], ENV['SIDEKIQ_PASSWORD']]
          end
        end

        Sidekiq::Web.use Rack::Session::Cookie, secret: ENV['SESSION_SECRET']
        run Rack::URLMap.new('/' => Sample::App, '/sidekiq' => Sidekiq::Web)
      CODE
      )

      assert_file('spec/example_worker_spec.rb')
    end
  end
  # rubocop:enable Metrics/MethodLength
end
