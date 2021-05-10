# frozen_string_literal: true

require_relative '../test_helper'

class GenerateClassicTest < IntegrationTestCase
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def test_generate_classic
    run_hoboken(:generate) do
      assert_file '.env'
      assert_file 'Gemfile'
      assert_file('Procfile')
      assert_file 'README.md'
      assert_file 'Rakefile'
      assert_file 'app.rb', /require 'sinatra'/
      assert_file 'app.rb', %r{require 'sinatra/flash'}
      assert_file 'app.rb', /require 'erubi'/
      assert_file 'app.rb', /erb :index/
      assert_file_does_not_have_content 'app.rb', /json message:/
      assert_file 'bin/console'
      assert_file 'bin/server'
      assert_file 'bin/setup'
      assert_file 'config.ru', /run Sinatra::Application/
      assert_file 'config/environment.rb', /set :erb, { escape_html: true }/
      assert_file 'config/environment.rb', /require 'better_errors'/
      assert_directory 'public'
      assert_directory 'test'
      assert_file 'views/index.erb'
      assert_file 'views/layout.erb', /styled_flash/
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

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
      assert_file_does_not_have_content(
        'config/environment.rb',
        /set :erb, { escape_html: true }/
      )
    end
  end

  def test_generate_api_only_with_tiny
    run_hoboken(:generate, api_only: true, tiny: true) do
      assert_file_does_not_have_content 'app.rb', /__END__/, /@@layout/, /@@index/
    end
  end

  def test_generate_with_ruby_version
    run_hoboken(:generate, run_tests: false, rubocop: false, ruby_version: '2.1.0') do
      assert_file 'Gemfile', /ruby '2\.1\.0'/
    end
  end

  def test_generate_with_git
    run_hoboken(:generate, run_tests: false, rubocop: false, git: true) do
      assert_directory '.git'
    end
  end
end
