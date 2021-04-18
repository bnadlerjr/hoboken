# frozen_string_literal: true

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
  end

  require_relative 'hoboken/add_ons/metrics'
  require_relative 'hoboken/add_ons/internationalization'
  require_relative 'hoboken/add_ons/heroku'
  require_relative 'hoboken/add_ons/omniauth'
  require_relative 'hoboken/add_ons/sequel'
  require_relative 'hoboken/add_ons/sprockets'
  require_relative 'hoboken/add_ons/travis'

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
      AddOns::Metrics,
      'add:metrics',
      'add:metrics',
      'Add metrics (flog, flay, simplecov)'
    )

    register(
      AddOns::Internationalization,
      'add:i18n',
      'add:i18n',
      'Internationalization support using sinatra-r18n'
    )

    register(
      AddOns::Heroku,
      'add:heroku',
      'add:heroku',
      'Heroku deployment support'
    )

    register(
      AddOns::OmniAuth,
      'add:omniauth',
      'add:omniauth',
      'OmniAuth authentication (allows you to select a provider)'
    )

    register(
      AddOns::Sprockets,
      'add:sprockets',
      'add:sprockets',
      'Rack-based asset packaging system'
    )

    register(
      AddOns::Sequel,
      'add:sequel',
      'add:sequel',
      'Database access via Sequel gem'
    )

    register(
      AddOns::Travis,
      'add:travis',
      'add:travis',
      'Basic Travis-CI YAML config'
    )
  end
end
