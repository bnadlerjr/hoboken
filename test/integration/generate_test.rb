# frozen_string_literal: true

require_relative '../test_helper'

class GenerateTest < IntegrationTestCase
  # rubocop:disable Metrics/MethodLength
  def test_generate_classic
    run_hoboken(:generate) do
      assert_file '.env'
      assert_file 'Gemfile'
      assert_file 'README.md'
      assert_file 'Rakefile'
      assert_file 'app.rb', /require 'sinatra'/
      assert_file 'app.rb', %r{require 'sinatra/flash'}
      assert_file 'app.rb', /require 'erubi'/
      assert_file 'app.rb', /erb :index/
      assert_file 'app.rb', /set :erb, { escape_html: true }/
      assert_file 'app.rb', /require 'better_errors'/
      assert_file_does_not_have_content 'app.rb', /json message:/
      assert_file 'config.ru', /run Sinatra::Application/
      assert_directory 'public'
      assert_directory 'test'
      assert_file 'views/index.erb'
      assert_file 'views/layout.erb', /styled_flash/
    end
  end
  # rubocop:enable Metrics/MethodLength

  def test_generate_classic_tiny
    run_hoboken(:generate, tiny: true) do
      refute_directory('public')
      assert_file 'app.rb', /__END__/, /@@layout/, /@@index/
    end
  end

  def test_generate_classic_api_only
    run_hoboken(:generate, api_only: true) do
      refute_directory('public')
      refute_directory('views')
      assert_file 'app.rb', %r{require 'sinatra/json'}
      assert_file 'app.rb', /json message:/
      assert_file_does_not_have_content 'app.rb', %r{require 'sinatra/flash'}
      assert_file_does_not_have_content 'app.rb', /erb :index/
      assert_file_does_not_have_content 'app.rb', /set :erb, { escape_html: true }/
    end
  end

  def test_generate_api_only_with_tiny
    run_hoboken(:generate, api_only: true, tiny: true) do
      assert_file_does_not_have_content 'app.rb', /__END__/, /@@layout/, /@@index/
    end
  end

  def test_generate_classic_can_run_tests
    run_hoboken(:generate) do
      result = execute('rake test:all')
      assert_match(/1 tests, 3 assertions, 0 failures, 0 errors/, result)
    end
  end

  def test_generate_classic_passes_rubocop_inspection
    run_hoboken(:generate) do
      assert_match(/no offenses detected/, execute('rubocop'))
    end
  end

  # rubocop:disable Metrics/MethodLength
  def test_generate_modular
    run_hoboken(:generate, type: :modular) do
      assert_file '.env'
      assert_file 'Gemfile'
      assert_file 'README.md'
      assert_file 'Rakefile'
      assert_file('app.rb', %r{require 'sinatra/base'})
      assert_file 'app.rb', %r{require 'sinatra/flash'}
      assert_file('app.rb', /require 'erubi'/)
      assert_file('app.rb', /module Sample/)
      assert_file('app.rb', /class App < Sinatra::Base/)
      assert_file 'app.rb', /set :erb, { escape_html: true }/
      assert_file 'app.rb', /register Sinatra::Flash/
      assert_file 'app.rb', /require 'better_errors'/
      assert_file 'config.ru', /run Sample::App/
      assert_directory 'public'
      assert_file 'test/test_helper.rb', /Sample::App/
      assert_file 'views/index.erb'
      assert_file 'views/layout.erb', /styled_flash/
    end
  end
  # rubocop:enable Metrics/MethodLength

  def test_generate_modular_tiny
    run_hoboken(:generate, tiny: true, type: :modular) do
      refute_directory('public')
      assert_file 'app.rb', /__END__/, /@@layout/, /@@index/
    end
  end

  def test_generate_modular_api_only
    run_hoboken(:generate, type: :modular, api_only: true) do
      refute_directory('public')
      refute_directory('views')
      assert_file 'app.rb', %r{require 'sinatra/json'}
      assert_file 'app.rb', /json message:/
      assert_file_does_not_have_content 'app.rb', %r{require 'sinatra/flash'}
      assert_file_does_not_have_content 'app.rb', /register Sinatra::Flash/
      assert_file_does_not_have_content 'app.rb', /erb :index/
      assert_file_does_not_have_content 'app.rb', /set :erb, { escape_html: true }/
    end
  end

  def test_generate_modular_can_run_tests
    run_hoboken(:generate, type: :modular) do
      result = execute('rake test:all')
      assert_match(/1 tests, 3 assertions, 0 failures, 0 errors/, result)
    end
  end

  def test_generate_modular_passes_rubocop_inspection
    run_hoboken(:generate, type: :modular) do
      assert_match(/no offenses detected/, execute('rubocop'))
    end
  end

  def test_generate_with_ruby_version
    run_hoboken(:generate, ruby_version: '2.1.0') do
      assert_file 'Gemfile', /ruby '2\.1\.0'/
    end
  end

  def test_generate_with_git
    run_hoboken(:generate, git: true) do
      assert_directory '.git'
    end
  end
end
