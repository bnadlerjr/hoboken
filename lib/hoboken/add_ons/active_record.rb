# frozen_string_literal: true

module Hoboken
  module AddOns
    # ActiveRecord database access via sinatra-activerecord gem.
    #
    class ActiveRecord < Hoboken::Group
      def add_gems
        gem 'sinatra-activerecord', version: '2.0'
        gem 'sqlite3', version: '1.4', group: %i[development test]
      end

      def setup_directories
        empty_directory('db/migrate')
        empty_directory('tasks')
      end

      def copy_example_seeds_file
        copy_file('hoboken/templates/seeds.rb', 'db/seeds.rb')
      end

      def copy_rake_task
        copy_file('hoboken/templates/active_record.rake', 'tasks/active_record.rake')
      end

      def require_sinatra_activerecord
        location = %r{require_relative '\.\./app'}
        insert_into_file('config/environment.rb', before: location) do
          "require 'sinatra/activerecord'\n\n"
        end
      end

      def set_database_variable
        snippet = "set :database, ENV['DATABASE_URL']"
        snippet = "register Sinatra::ActiveRecordExtension\n#{snippet}" if modular?
        indentation = classic? ? 2 : 6
        location = /set :erb.+\n/
        insert_into_file('config/environment.rb', after: location) do
          "\n#{indent(snippet, indentation)}\n"
        end
      end

      def setup_puma_config
        insert_into_file('config/puma.rb', after: 'on_worker_boot do') do
          "\n    ActiveRecord::Base.establish_connection"
        end
      end

      # rubocop:disable Metrics/MethodLength
      def add_database_test_helper_class
        return if rspec?

        insert_into_file('test/test_helper.rb', before: /ENV\['RACK_ENV'\] = 'test'/) do
          "ENV['DATABASE_URL'] = 'sqlite3:db/test.db'\n"
        end

        append_file('test/test_helper.rb') do
          <<~CODE

            module Test
              module Database
                class TestCase < Test::Unit::TestCase
                  def run(*args, &block)
                    result = nil
                    ActiveRecord::Base.connection.transaction do
                      result = super
                      raise ActiveRecord::Rollback
                    end
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
          "ENV['DATABASE_URL'] = 'sqlite3:db/test.db'\n"
        end

        snippet_rack = <<~CODE
          config.around(:example, rack: true) do |example|
            ActiveRecord::Base.transaction do
              example.run
              ActiveRecord::Rollback
            end
          end
        CODE

        snippet_database = <<~CODE
          config.around(:example, database: true) do |example|
            ActiveRecord::Base.transaction do
              example.run
              ActiveRecord::Rollback
            end
          end
        CODE

        location = /RSpec\.configure do \|config\|\n/
        insert_into_file('spec/spec_helper.rb', after: location) do
          "#{indent(snippet_rack, 2)}\n#{indent(snippet_database, 2)}\n"
        end
      end
      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/MethodLength
      def update_readme
        snippet = <<~CODE
          <tr>
              <td>DATABASE_URL</td>
              <td>Yes</td>
              <td>
                `sqlite3:db/test.db` (for the test environment <em>only</em>)
              </td>
              <td>
                Connection URL to the database. The format varies according
                database adapter. Refer to the documentation for the adapter
                you're using for more information. Some examples:
                <dl>
                  <dt>Sqlite3</dt>
                  <dd>`sqlite3:db/development.db`</dd>
                  <dt>PostgreSQL</dt>
                  <dd>`postgresql://localhost/myapp_development?pool=5`</dd>
                </dl>
              </td>
          </tr>
        CODE

        insert_into_file('README.md', after: /<tbody>\n/) do
          indent(snippet, 8)
        end
      end
      # rubocop:enable Metrics/MethodLength

      def reminders
        say "\nGemfile updated... don't forget to 'bundle install'"
        say <<~TEXT

          Notes:
            * The sqlite3 gem has been installed for dev and test environments
              only. You will need to specify a gem to use for production.

            * You will need to specify an environment variable 'DATABASE_URL'
              (either add it to .env or export it). For example, in your .env
              file add: `DATABASE_URL=sqlite3:db/development.db`.
        TEXT
      end
    end
  end
end
