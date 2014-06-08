module Hoboken
  module AddOns
    class Internationalization < ::Hoboken::Group
      def add_gem
        gem "sinatra-r18n", version: "1.1.5"
        insert_into_file("app.rb", after: /require "sinatra("|\/base")/) do
          "\nrequire \"sinatra/r18n\""
        end
        insert_into_file("app.rb", after: /Sinatra::Base/) do
          "\n    register Sinatra::R18n"
        end
      end

      def translations
        empty_directory("i18n")
        template("hoboken/templates/en.yml.tt", "i18n/en.yml")
      end

      def reminders
        say "\nGemfile updated... don't forget to 'bundle install'"
      end
    end
  end
end
