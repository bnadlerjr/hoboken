# frozen_string_literal: true

require_relative '../test_helper'

class GitHubActionTest < IntegrationTestCase
  def test_github_action_add_on
    run_hoboken(:generate, run_tests: false, rubocop: false) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:github_action")
      assert_file('.github/workflows/ruby.yml')
    end
  end
end
