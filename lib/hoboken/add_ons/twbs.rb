# frozen_string_literal: true

module Hoboken
  module AddOns
    # Twitter Bootstrap support.
    #
    class TwitterBootstrap < ::Hoboken::Group
      def add_gem
        return unless sprockets?

        gem 'bootstrap', version: '5.0.0.beta3', group: :assets
      end

      def update_app
        return unless sprockets?

        indentation = classic? ? 2 : 6
        insert_into_file('app.rb', after: /require.*sprockets_chain.*\n/) do
          indent("require 'bootstrap'\n", indentation)
        end
      end

      def update_asset_files
        return unless sprockets?

        prepend_file('assets/styles.scss') do
          <<~CODE
            @import "bootstrap";

          CODE
        end

        prepend_file('assets/app.js') do
          <<~CODE
            //= require popper
            //= require bootstrap-sprockets
          CODE
        end
      end

      def update_sprockets_rake_tasks
        return unless sprockets?

        insert_into_file('tasks/sprockets.rake', after: /require 'sprockets'\n/) do
          "  require 'bootstrap'\n"
        end
      end

      def remove_normalize_css
        return unless sprockets?

        gsub_file(
          'views/layout.erb',
          '<link rel="stylesheet" type="text/css" ' \
          'href="//cdnjs.cloudflare.com/ajax/libs/normalize/2.1.3/normalize.min.css">',
          ''
        )
      end

      def reminders
        if sprockets?
          say "\nGemfile updated... don't forget to 'bundle install'"
        else
          text = <<~TEXT
            Sprockets is required. Please install the Sprockets add-on
            first (hoboken add:sprockets).
          TEXT

          say text, :red
        end
      end

      private

      def sprockets?
        Dir.exist?('assets')
      end
    end
  end
end
