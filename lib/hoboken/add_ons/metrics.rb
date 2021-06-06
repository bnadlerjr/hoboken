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

      def simplecov_test_unit
        return if rspec?

        insert_into_file 'test/test_helper.rb', before: snippet_location do
          snippet('test')
        end
      end

      def simplecov_rspec
        return unless rspec?

        insert_into_file 'spec/spec_helper.rb', before: snippet_location do
          snippet('spec')
        end
      end

      def reminders
        say "\nGemfile updated... don't forget to 'bundle install'"
      end

      private

      def snippet(framework_folder)
        <<~CODE
          require 'simplecov'
          SimpleCov.start do
            add_filter '/bin/'
            add_filter '/config/'
            add_filter '/db/migrate/'
            add_filter '/#{framework_folder}/'
            coverage_dir 'tmp/coverage'
          end

        CODE
      end

      def snippet_location
        %r{require_relative '\.\./config/environment'}
      end
    end
  end
end
