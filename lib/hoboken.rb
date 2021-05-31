# frozen_string_literal: true

require 'date'
require 'thor'
require 'thor/util'
require 'fileutils'
require_relative 'hoboken/version'
require_relative 'hoboken/generate'
require_relative 'hoboken/actions'

# Generate Sinatra project templates.
#
module Hoboken
  # Custom `Thor::Group` that mixes in `Hoboken::Actions` so that they're
  # available everywhere.
  #
  class Group < Thor::Group
    include Thor::Actions
    include Hoboken::Actions

    def self.source_root
      File.dirname(__FILE__)
    end

    def classic?
      File.read('app.rb').include?("require 'sinatra'")
    end

    def rspec?
      Dir.exist?('spec')
    end

    def rubocop?
      File.exist?('.rubocop.yml')
    end

    def sequel?
      File.exist?('tasks/sequel.rake')
    end
  end

  require_relative 'hoboken/add_ons/airbrake'
  require_relative 'hoboken/add_ons/github_action'
  require_relative 'hoboken/add_ons/heroku'
  require_relative 'hoboken/add_ons/internationalization'
  require_relative 'hoboken/add_ons/metrics'
  require_relative 'hoboken/add_ons/omniauth'
  require_relative 'hoboken/add_ons/rubocop'
  require_relative 'hoboken/add_ons/sequel'
  require_relative 'hoboken/add_ons/sidekiq'
  require_relative 'hoboken/add_ons/travis'
  require_relative 'hoboken/add_ons/turnip'
  require_relative 'hoboken/add_ons/twbs'
  require_relative 'hoboken/add_ons/vcr'

  # Hoboken's command-line interface.
  #
  class CLI < Thor
    desc 'version', 'Print version and quit'
    def version
      puts "Hoboken v#{Hoboken::VERSION}"
    end

    register(Generate, 'generate', 'generate [APP_NAME]', 'Generate a new Sinatra app')
    tasks['generate'].options = Hoboken::Generate.class_options

    register(
      AddOns::Airbrake,
      'add:airbrake',
      'add:airbrake',
      'Support for official Airbrake library for Ruby applications'
    )

    register(
      AddOns::GithubAction,
      'add:github_action',
      'add:github_action',
      'Github action that runs CI task'
    )

    register(
      AddOns::Heroku,
      'add:heroku',
      'add:heroku',
      'Heroku deployment support'
    )

    register(
      AddOns::Internationalization,
      'add:i18n',
      'add:i18n',
      'Internationalization support using sinatra-r18n'
    )

    register(
      AddOns::Metrics,
      'add:metrics',
      'add:metrics',
      'Add metrics (flog, flay, simplecov)'
    )

    register(
      AddOns::OmniAuth,
      'add:omniauth',
      'add:omniauth',
      'OmniAuth authentication (allows you to select a provider)'
    )

    register(
      AddOns::Rubocop,
      'add:rubocop',
      'add:rubocop',
      'Basic Rubocop configuration and Rake task.'
    )

    register(
      AddOns::Sequel,
      'add:sequel',
      'add:sequel',
      'Database access via Sequel gem'
    )

    register(
      AddOns::Sidekiq,
      'add:sidekiq',
      'add:sidekiq',
      'Background processing with the Sidekiq gem'
    )

    register(
      AddOns::Travis,
      'add:travis',
      'add:travis',
      'Basic Travis-CI YAML config'
    )

    register(
      AddOns::Turnip,
      'add:turnip',
      'add:turnip',
      'Gherkin extension for RSpec'
    )

    register(
      AddOns::TwitterBootstrap,
      'add:twbs',
      'add:twbs',
      'Twitter Bootstrap'
    )

    register(
      AddOns::Vcr,
      'add:vcr',
      'add:vcr',
      'Record HTTP interactions and replay them during test runs'
    )

    def self.exit_on_failure?
      true
    end
  end
end
