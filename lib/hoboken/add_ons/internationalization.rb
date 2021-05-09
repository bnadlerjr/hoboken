# frozen_string_literal: true

module Hoboken
  module AddOns
    # Internationalization support using sinatra-r18n.
    #
    class Internationalization < ::Hoboken::Group
      def add_gem
        gem 'sinatra-r18n', version: '5.0'
        insert_into_file('app.rb', after: %r{require 'sinatra('|/base')}) do
          "\nrequire 'sinatra/r18n'"
        end
        insert_into_file('config/environment.rb', after: /register Sinatra::Flash/) do
          "\n      register Sinatra::R18n"
        end
      end

      def translations
        empty_directory('i18n')
        template('hoboken/templates/en.yml.tt', 'i18n/en.yml')
      end

      def reminders
        say "\nGemfile updated... don't forget to 'bundle install'"
      end
    end
  end
end
