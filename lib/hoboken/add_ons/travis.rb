# frozen_string_literal: true

module Hoboken
  module AddOns
    # Basic Travis-CI YAML config.
    #
    class Travis < ::Hoboken::Group
      def travis_yml
        create_file('.travis.yml') do
          'language: ruby'
        end
      end
    end
  end
end
