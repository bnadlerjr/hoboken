# frozen_string_literal: true

module Hoboken
  module AddOns
    # Basic Rubocop YAML config.
    #
    class Rubocop < ::Hoboken::Group
      def add_gems
        gem 'rubocop', version: '1.12', group: %i[development test]
        gem 'rubocop-rake', version: '0.5', group: %i[development test]
      end

      def rubocop_yml
        template('hoboken/templates/rubocop.yml.tt', '.rubocop.yml')
      end

      def rake_task
        create_file('tasks/rubocop.rake') do
          <<~TEXT
            # frozen_string_literal: true

            require 'rubocop/rake_task'

            RuboCop::RakeTask.new
          TEXT
        end
      end
    end
  end
end