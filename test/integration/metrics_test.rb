# frozen_string_literal: true

require_relative '../test_helper'

class MetricsTest < IntegrationTestCase
  # rubocop:disable Metrics/MethodLength
  def test_metrics_add_on
    run_hoboken(:generate) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:metrics")
      assert_file('Gemfile', /flog/, /flay/, /simplecov/)
      assert_file('tasks/metrics.rake')

      assert_file('test/test_helper.rb', <<~CODE
        require 'simplecov'
        SimpleCov.start do
          add_filter '/bin/'
          add_filter '/config/'
          add_filter '/test/'
          coverage_dir 'tmp/coverage'
        end

      CODE
      )

      assert_match(/no offenses detected/, execute('rubocop'))
    end
  end
  # rubocop:enable Metrics/MethodLength
end
