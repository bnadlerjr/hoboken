# frozen_string_literal: true

require_relative '../test_helper'

class RubocopTest < IntegrationTestCase
  def test_rubocop_add_on
    run_hoboken(:generate, run_tests: false) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:rubocop")
      assert_file('Gemfile', /rubocop/, /rubocop-rake/)
      assert_file_does_not_have_content 'Gemfile', /rubocop-rspec/
      assert_file('tasks/rubocop.rake', %r{rubocop/rake_task}, /RuboCop::RakeTask\.new/)
      assert_file('Rakefile', /task ci: \['test:all', 'rubocop'\]/)
      assert_file('.rubocop.yml', '- rubocop-rake')
      assert_file('.rubocop.yml', "TargetRubyVersion: #{RUBY_VERSION}")
    end
  end

  def test_rubocop_with_rspec_add_on
    run_hoboken(:generate, run_tests: false, test_framework: 'rspec') do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:rubocop")
      assert_file('Gemfile', /rubocop/, /rubocop-rspec/)
      assert_file('tasks/rubocop.rake', %r{rubocop/rake_task}, /RuboCop::RakeTask\.new/)
      assert_file('Rakefile', /task ci: .*spec rubocop/)
      assert_file('.rubocop.yml', '- rubocop-rspec')
    end
  end
end
