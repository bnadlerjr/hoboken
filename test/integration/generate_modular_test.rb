# frozen_string_literal: true

require_relative '../test_helper'

class GenerateModularTest < IntegrationTestCase
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def test_generate_modular
    run_hoboken(:generate, type: :modular) do
      assert_file '.env'
      assert_file 'Gemfile'
      assert_file('Procfile')
      assert_file 'README.md'
      assert_file 'Rakefile'
      assert_file('app.rb', %r{require 'sinatra/base'})
      assert_file 'app.rb', %r{require 'sinatra/flash'}
      assert_file('app.rb', /require 'erubi'/)
      assert_file('app.rb', /module Sample/)
      assert_file('app.rb', /class App < Sinatra::Base/)
      assert_file 'bin/console'
      assert_file 'bin/server'
      assert_file 'bin/setup'
      assert_file 'config.ru', /run Sample::App/
      assert_file 'config/environment.rb', /set :erb, { escape_html: true }/
      assert_file 'config/environment.rb', /register Sinatra::Flash/
      assert_file 'config/environment.rb', /require 'better_errors'/
      assert_directory 'public'
      assert_file 'test/support/rack_helpers.rb', /Sample::App/
      assert_file 'views/index.erb'
      assert_file 'views/layout.erb', /styled_flash/
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def test_generate_modular_tiny
    # FIXME: For some reason modular apps can't find the inline templates even
    # if `enable :inline_templates is set. This is a bit of an edge case since
    # most apps with inline templates are of the classic variety.
    run_hoboken(:generate, run_tests: false, tiny: true, type: :modular) do
      refute_directory('public')
      assert_file 'app.rb', /__END__/, /@@layout/, /@@index/
    end
  end

  # rubocop:disable Metrics/MethodLength
  def test_generate_modular_api_only
    run_hoboken(:generate, type: :modular, api_only: true) do
      refute_directory('public')
      refute_directory('views')
      assert_file 'app.rb', %r{require 'sinatra/json'}
      assert_file 'app.rb', /json message:/
      assert_file_does_not_have_content 'app.rb', /erb :index/

      assert_file_does_not_have_content(
        'config/environment.rb',
        %r{require 'sinatra/flash'}
      )

      assert_file_does_not_have_content(
        'config/environment.rb',
        /register Sinatra::Flash/
      )

      assert_file_does_not_have_content(
        'config/environment.rb',
        /set :erb, { escape_html: true }/
      )
    end
  end
  # rubocop:enable Metrics/MethodLength

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
