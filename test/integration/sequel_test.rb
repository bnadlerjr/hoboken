# frozen_string_literal: true

require_relative '../test_helper'

class SequelTest < IntegrationTestCase
  # rubocop:disable Metrics/MethodLength
  def test_sequel_add_on
    run_hoboken(:generate) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:sequel")
      assert_file('Gemfile', 'sequel', 'sqlite3')
      assert_file('tasks/sequel.rake')
      assert_file('config/db.rb')

      assert_file(
        'test/test_helper.rb',
        %r{ENV\['DATABASE_URL'\] = 'sqlite://db/test\.db'}
      )

      assert_file('test/test_helper.rb', /require 'sequel'/)
      assert_file('test/test_helper.rb', <<~CODE
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
      )
    end
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def test_sequel_add_on_with_rspec
    run_hoboken(:generate, test_framework: 'rspec') do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:sequel")

      assert_file(
        'spec/spec_helper.rb',
        %r{ENV\['DATABASE_URL'\] = 'sqlite://db/test\.db'}
      )

      assert_file('spec/spec_helper.rb', <<-CODE
  config.around(:example, rack: true) do |example|
    DB.transaction(rollback: :always) { example.run }
  end

  config.around(:example, database: true) do |example|
    DB.transaction(rollback: :always) { example.run }
  end

      CODE
      )
    end
  end
  # rubocop:enable Metrics/MethodLength

  def test_sequel_add_on_with_rubocop
    run_hoboken(:generate) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:rubocop")
      execute("#{bin_path} add:sequel")
      assert_file('Gemfile', /rubocop-sequel/)
      assert_file('.rubocop.yml', /- rubocop-sequel/)
    end
  end
end
