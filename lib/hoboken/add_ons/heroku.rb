# frozen_string_literal: true

module Hoboken
  module AddOns
    # Heroku deployment support.
    #
    class Heroku < ::Hoboken::Group
      def add_gem
        gem 'foreman', version: '0.63.0', group: :development
      end

      def procfile
        create_file('Procfile') do
          'web: bundle exec thin start -p $PORT -e $RACK_ENV'
        end
      end

      def slugignore
        create_file('.slugignore') do
          "tags\n/test\n/tmp"
        end
      end

      def fix_stdout_for_logging
        prepend_file('config.ru', "$stdout.sync = true\n")
      end

      def replace_server_rake_task
        gsub_file('Rakefile', /desc.*server.*{rack_env}"\)\nend$/m) do
          <<~TASK
            desc 'Start the development server with Foreman'
            task :server do
              exec('foreman start')
            end
          TASK
        end
      end

      def reminders
        say "\nGemfile updated... don't forget to 'bundle install'"
      end
    end
  end
end
