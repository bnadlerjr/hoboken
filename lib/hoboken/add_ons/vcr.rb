# frozen_string_literal: true

module Hoboken
  module AddOns
    # Record your test suite's HTTP interactions and replay them during
    # future test runs.
    #
    class Vcr < ::Hoboken::Group
      def add_gems
        gem 'vcr', version: '6.0', group: :test
        gem 'webmock', version: '3.13', group: :test
      end

      def add_directories
        empty_directory(File.join(location, 'fixtures', 'vcr_cassettes'))
      end

      def add_setup_file
        template(
          'hoboken/templates/vcr_setup.rb.tt',
          File.join(location, 'support/vcr_setup.rb')
        )
      end

      def require_vcr_in_test_helper
        return if rspec?

        snippet_location = "require_relative 'support/rack_helpers'"
        insert_into_file('test/test_helper.rb', after: snippet_location) do
          "\nrequire_relative 'support/vcr_setup'"
        end
      end

      def require_vcr_in_spec_helper
        return unless rspec?

        snippet_location = "require 'support/rack_helpers'"
        insert_into_file('spec/spec_helper.rb', after: snippet_location) do
          "\nrequire 'support/vcr_setup'"
        end
      end

      def reminders
        say "Gemfile updated... don't forget to 'bundle install'", :green
      end

      private

      def location
        rspec? ? 'spec' : 'test'
      end
    end
  end
end
