# frozen_string_literal: true

require_relative '../test_helper'

class GitHubActionTest < IntegrationTestCase
  def test_github_action_add_on
    run_hoboken(:generate) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:github_action")
      assert_file('.github/workflows/ruby.yml')
      assert_match(/no offenses detected/, execute('rubocop'))
    end
  end
end
