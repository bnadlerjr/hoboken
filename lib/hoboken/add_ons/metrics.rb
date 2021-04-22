# frozen_string_literal: true

module Hoboken
  module AddOns
    # Add metrics (flog, flay, simplecov).
    #
    class Metrics < ::Hoboken::Group
      def add_gems
        gem 'flog', version: '4.6', group: :test
        gem 'flay', version: '2.12', group: :test
        gem 'simplecov', version: '0.21', require: false, group: :test
      end

      def copy_task_templates
        empty_directory('tasks')
        template('hoboken/templates/metrics.rake.tt', 'tasks/metrics.rake')
      end

      def simplecov_snippet
        insert_into_file 'test/test_helper.rb', before: %r{require 'test/unit'} do
          <<~CODE

            require 'simplecov'
            SimpleCov.start do
              add_filter '/test/'
              coverage_dir 'tmp/coverage'
            end

          CODE
        end
      end

      def reminders
        say "\nGemfile updated... don't forget to 'bundle install'"
      end
    end
  end
end
