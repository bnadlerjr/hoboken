require_relative "../test_helper"

class AddOnTest < IntegrationTestCase
  def test_metrics_add_on
    run_hoboken(:generate) do
      bin_path = File.expand_path("../../../bin/hoboken", __FILE__)
      execute("#{bin_path} add:metrics")
      assert_file("Gemfile", /flog/, /flay/, /simplecov/)
      assert_file("tasks/metrics.rake")
      assert_file("test/test_helper.rb",
<<CODE

require 'simplecov'
SimpleCov.start do
  add_filter "/test/"
  coverage_dir 'tmp/coverage'
end

CODE
                 )
    end
  end
end
