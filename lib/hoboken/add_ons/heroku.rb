# frozen_string_literal: true

module Hoboken
  module AddOns
    # Heroku deployment support.
    #
    class Heroku < ::Hoboken::Group
      def slugignore
        create_file('.slugignore') do
          "tags\n/test\n/tmp"
        end
      end

      def fix_stdout_for_logging
        insert_into_file('config.ru', after: /# frozen_string_literal: true/) do
          "\n\n$stdout.sync = true"
        end
      end

      def reminders
        say "\nGemfile updated... don't forget to 'bundle install'"
      end
    end
  end
end
