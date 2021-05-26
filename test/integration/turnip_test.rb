# frozen_string_literal: true

require_relative '../test_helper'

class TurnipTest < IntegrationTestCase
  def test_turnip_add_on_classic
    run_hoboken(:generate, test_framework: 'rspec') do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      result = execute("#{bin_path} add:turnip")
      assert_match(/Gemfile updated/, result)

      assert_file('Gemfile', /turnip/)
      assert_file('Rakefile', /task ci: %w\[spec turnip\]/)
      assert_file('Rakefile', /task default: %w\[spec turnip\]/)
      assert_file('spec/features/example.feature')
      assert_file('spec/support/steps/example_steps.rb')
      assert_file('spec/turnip_helper.rb')
      assert_file('tasks/turnip.rake')

      assert_directory('spec/features')
      assert_directory('spec/support/steps')
    end
  end

  def test_turnip_add_on_modular
    run_hoboken(:generate, type: :modular, test_framework: 'rspec') do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      result = execute("#{bin_path} add:turnip")
      assert_match(/Gemfile updated/, result)

      assert_file('Gemfile', /turnip/)
      assert_file('Rakefile', /task ci: %w\[spec turnip\]/)
      assert_file('Rakefile', /task default: %w\[spec turnip\]/)
      assert_file('spec/features/example.feature')
      assert_file('spec/support/steps/example_steps.rb')
      assert_file('spec/turnip_helper.rb')
      assert_file('tasks/turnip.rake')

      assert_directory('spec/features')
      assert_directory('spec/support/steps')
    end
  end

  def test_turnip_without_rspec
    run_hoboken(:generate, rubocop: false, run_tests: false) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      result = execute("#{bin_path} add:turnip")
      assert_match(/Turnip requires RSpec/, result)
    end
  end
end
