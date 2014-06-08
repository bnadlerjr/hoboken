module Hoboken
  module AddOns
    class Travis < ::Hoboken::Group
      def travis_yml
        create_file(".travis.yml") do
          "language: ruby"
        end
      end
    end
  end
end
