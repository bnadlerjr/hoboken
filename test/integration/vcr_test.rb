# frozen_string_literal: true

require_relative '../test_helper'

class VcrTest < IntegrationTestCase
  # rubocop:disable Metrics/MethodLength
  def test_vcr_add_on_test_unit
    run_hoboken(:generate) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      result = execute("#{bin_path} add:vcr")
      assert_match(/Gemfile updated/, result)

      assert_file('Gemfile', /vcr/)
      assert_file('Gemfile', /webmock/)
      assert_file('test/support/vcr_setup.rb')
      assert_file('test/test_helper.rb', "require_relative 'support/vcr_setup'")

      assert_file(
        'test/support/vcr_setup.rb',
        "c.cassette_library_dir = 'test/fixtures/vcr_cassettes'"
      )

      assert_file_does_not_have_content(
        'test/support/vcr_setup.rb',
        'c.configure_rspec_metadata!'
      )

      assert_directory('test/fixtures/vcr_cassettes')
    end
  end
  # rubocop:enable Metrics/MethodLength

  def test_vcr_add_on_rspec
    run_hoboken(:generate, test_framework: 'rspec') do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      result = execute("#{bin_path} add:vcr")
      assert_match(/Gemfile updated/, result)

      assert_file('Gemfile', /vcr/)
      assert_file('Gemfile', /webmock/)
      assert_file('spec/support/vcr_setup.rb')
      assert_file('spec/spec_helper.rb', "require 'support/vcr_setup'")

      assert_file(
        'spec/support/vcr_setup.rb',
        "c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'"
      )

      assert_file('spec/support/vcr_setup.rb', 'c.configure_rspec_metadata!')

      assert_directory('spec/fixtures/vcr_cassettes')
    end
  end
end
