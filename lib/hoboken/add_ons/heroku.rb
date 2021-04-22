# frozen_string_literal: true

module Hoboken
  module AddOns
    # Heroku deployment support.
    #
    class Heroku < ::Hoboken::Group
      def add_gem
        gem 'foreman', version: '0.87', group: :development
      end

      def procfile
        create_file('Procfile') do
          'web: bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-development}'
        end
      end

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

      def replace_server_rake_task
        gsub_file('Rakefile', /desc.*server.*{rack_env}"\)\nend\n$/m) do
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
