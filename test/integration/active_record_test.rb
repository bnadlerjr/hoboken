# frozen_string_literal: true

require_relative '../test_helper'

class ActiveRecord < IntegrationTestCase
  # rubocop:disable Metrics/MethodLength
  def test_activerecord_add_on
    run_hoboken(:generate) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:active_record")
      execute('echo "DATABASE_URL=sqlite3:db/development.db" > .env')

      assert_file('Gemfile', 'sinatra-activerecord', 'sqlite3')
      assert_file('db/seeds.rb')
      assert_file('tasks/active_record.rake')

      assert_file('config/environment.rb', "require 'sinatra/activerecord'")
      assert_file('config/puma.rb', 'ActiveRecord::Base.establish_connection')

      assert_file(
        'test/test_helper.rb',
        %r{ENV\['DATABASE_URL'\] = 'sqlite3:db/test\.db'}
      )

      assert_file('test/test_helper.rb', <<~CODE
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
      )
    end
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def test_activerecord_add_on_with_rspec
    run_hoboken(:generate, test_framework: 'rspec') do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:active_record")
      execute("#{bin_path} add:rubocop")
      execute('echo "DATABASE_URL=sqlite3:db/development.db" > .env')

      assert_file(
        'spec/spec_helper.rb',
        %r{ENV\['DATABASE_URL'\] = 'sqlite3:db/test\.db'}
      )

      assert_file('spec/spec_helper.rb', <<-CODE
  config.around(:example, rack: true) do |example|
    ActiveRecord::Base.transaction do
      example.run
      ActiveRecord::Rollback
    end
  end

  config.around(:example, database: true) do |example|
    ActiveRecord::Base.transaction do
      example.run
      ActiveRecord::Rollback
    end
  end

      CODE
      )
    end
  end
  # rubocop:enable Metrics/MethodLength
end
