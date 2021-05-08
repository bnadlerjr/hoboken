# frozen_string_literal: true

require_relative '../test_helper'

class TravisTest < IntegrationTestCase
  def test_travis_add_on
    run_hoboken(:generate) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:travis")
      assert_file('.travis.yml', 'language: ruby')
    end
  end
end
