# frozen_string_literal: true

module Hoboken
  module AddOns
    # Database access via Sequel gem.
    #
    class Sequel < ::Hoboken::Group
      def add_gems
        gem 'sequel', version: '5.43'
        gem 'sqlite3', version: '1.4', group: %i[development test]
        gem 'rubocop-sequel', version: '0.2', group: %i[development test] if rubocop?
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
          "\n    Sequel::DATABASES.each(&:disconnect)"
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

        snippet = <<~CODE
          def run(*args, &block)
            result = nil
            DB.transaction(rollback: :always) { result = super }
            result
          end
        CODE

        insert_into_file('test/test_helper.rb', after: /include RackHelpers\n/) do
          "\n#{indent(snippet, 6)}"
        end
      end
      # rubocop:enable Metrics/MethodLength

      def add_database_spec_helper
        return unless rspec?

        insert_into_file('spec/spec_helper.rb', before: /ENV\['RACK_ENV'\] = 'test'/) do
          "ENV['DATABASE_URL'] = 'sqlite://db/test.db'\n"
        end

        snippet = <<~CODE
          config.around do |example|
            DB.transaction(rollback: :always) { example.run }
          end
        CODE

        location = /RSpec\.configure do \|config\|\n/
        insert_into_file('spec/spec_helper.rb', after: location) do
          "#{indent(snippet, 2)}\n"
        end
      end

      def update_rubocop_config
        return unless rubocop?

        insert_into_file('.rubocop.yml', after: /require:\n/) do
          "    - rubocop-sequel\n"
        end
      end

      # rubocop:disable Metrics/MethodLength
      def update_readme
        snippet = <<~CODE
          <tr>
              <td>DATABASE_URL</td>
              <td>Yes</td>
              <td>
                `sqlite://db/test.db` (for the test environment <em>only</em>)
              </td>
              <td>
                Connection URL to the database. The format varies according
                database adapter. Refer to the
                <a href="https://sequel.jeremyevans.net/rdoc/files/doc/opening_databases_rdoc.html">
                Sequel gem documentation</a> for more information. Some examples:
                <dl>
                  <dt>Sqlite3</dt>
                  <dd>`sqlite://db/development.db`</dd>
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
            * The sqlite3 gem has been installed for dev and test environments only. You will need to specify a gem to use for production.
            * You will need to specify an environment variable 'DATABASE_URL' (either add it to .env or export it)
        TEXT
      end
    end
  end
end
