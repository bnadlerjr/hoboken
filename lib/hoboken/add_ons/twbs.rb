# frozen_string_literal: true

module Hoboken
  module AddOns
    # Twitter Bootstrap support.
    #
    class TwitterBootstrap < ::Hoboken::Group
      def add_gem
        gem 'bootstrap', version: '5.0.0.beta3', group: :assets
      end

      def update_app
        indentation = classic? ? 2 : 6
        location = /configure do\n/
        insert_into_file('config/environment.rb', after: location) do
          indent("require 'bootstrap'\n", indentation)
        end
      end

      def update_asset_files
        prepend_file('assets/stylesheets/styles.scss') do
          <<~CODE
            @import "bootstrap";

          CODE
        end

        prepend_file('assets/javascripts/app.js') do
          <<~CODE
            //= require popper
            //= require bootstrap-sprockets
          CODE
        end
      end

      def remove_normalize_css
        gsub_file(
          'views/layout.erb',
          '<link rel="stylesheet" type="text/css" ' \
          'href="//cdnjs.cloudflare.com/ajax/libs/normalize/2.1.3/normalize.min.css">',
          ''
        )
      end

      def reminders
        say "\nGemfile updated... don't forget to 'bundle install'"
      end
    end
  end
end
