# frozen_string_literal: true

module Hoboken
  module AddOns
    # Basic Rubocop YAML config.
    #
    class Rubocop < ::Hoboken::Group
      def add_gems
        gem 'rubocop', version: '1.12', group: %i[development test]
        gem 'rubocop-rake', version: '0.5', group: %i[development test]
        gem 'rubocop-rspec', version: '2.2', group: %i[development test] if rspec?
        gem 'rubocop-sequel', version: '0.2', group: %i[development test] if sequel?
      end

      def rubocop_yml
        template('hoboken/templates/rubocop.yml.tt', '.rubocop.yml')
      end

      def rake_task
        create_file('tasks/rubocop.rake') do
          <<~TEXT
            # frozen_string_literal: true

            begin
              require 'rubocop/rake_task'
              RuboCop::RakeTask.new
            # rubocop:disable Lint/SuppressedException
            rescue LoadError
            end
            # rubocop:enable Lint/SuppressedException
          TEXT
        end
      end

      def ci_task
        task_list = if rspec?
                      '%w[spec rubocop]'
                    else
                      "['test:all', 'rubocop']"
                    end
        gsub_file('Rakefile', /task ci:.*/, "task ci: #{task_list}")
      end
    end
  end
end
