# frozen_string_literal: true

module Hoboken
  module AddOns
    # Database access via Sequel gem.
    #
    class Sequel < ::Hoboken::Group
      def add_gems
        gem 'sequel', version: '5.43'
        gem 'sqlite3', version: '1.4', group: %i[development test]
      end

      def setup_directories
        empty_directory('db/migrate')
        empty_directory('tasks')
        empty_directory('tmp')
      end

      def copy_rake_task
        copy_file('hoboken/templates/sequel.rake', 'tasks/sequel.rake')
      end

      def setup_db_config
        template('hoboken/templates/db.rb.tt', 'config/db.rb')
      end

      def require_db_config
        location = %r{require_relative '\.\./app'}
        insert_into_file('config/environment.rb', before: location) do
          "require_relative 'db'\n\n"
        end
      end

      def setup_puma_config
        insert_into_file('config/puma.rb', after: 'before_fork do') do
          "\n    DB.disconnect if defined?(DB)"
        end
      end

      # rubocop:disable Metrics/MethodLength
      def add_database_test_helper_class
        return if rspec?

        insert_into_file('test/test_helper.rb', before: /ENV\['RACK_ENV'\] = 'test'/) do
          "ENV['DATABASE_URL'] = 'sqlite://db/test.db'\n"
        end

        insert_into_file('test/test_helper.rb', after: %r{require 'test/unit'}) do
          "\nrequire 'sequel'"
        end

        append_file('test/test_helper.rb') do
          <<~CODE

            module Test
              module Database
                class TestCase < Test::Unit::TestCase
                  def run(*args, &block)
                    result = nil
                    DB.transaction(rollback: :always) { result = super }
                    result
                  end
                end
              end
            end
          CODE
        end
      end
      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/MethodLength
      def add_database_spec_helper
        return unless rspec?

        insert_into_file('spec/spec_helper.rb', before: /ENV\['RACK_ENV'\] = 'test'/) do
          "ENV['DATABASE_URL'] = 'sqlite://db/test.db'\n"
        end

        snippet_rack = <<~CODE
          config.around(:example, rack: true) do |example|
            DB.transaction(rollback: :always) { example.run }
          end
        CODE

        snippet_database = <<~CODE
          config.around(:example, database: true) do |example|
            DB.transaction(rollback: :always) { example.run }
          end
        CODE

        location = /RSpec\.configure do \|config\|\n/
        insert_into_file('spec/spec_helper.rb', after: location) do
          "#{indent(snippet_rack, 2)}\n#{indent(snippet_database, 2)}\n"
        end
      end
      # rubocop:enable Metrics/MethodLength

      def reminders
        say "\nGemfile updated... don't forget to 'bundle install'"
        say <<~TEXT

          Notes:
            * The sqlite3 gem has been installed for dev and test environments only. You will need to specify a gem to use for production.
            * You will need to specify an environment variable 'DATABASE_URL' (either add it to .env or export it)
        TEXT
      end
    end
  end
end
