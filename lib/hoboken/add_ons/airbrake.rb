# frozen_string_literal: true

module Hoboken
  module AddOns
    # Support for official Airbrake library for Ruby applications.
    #
    class Airbrake < ::Hoboken::Group
      def add_gem
        gem 'airbrake', version: '11.0'
      end

      def setup_config
        template('hoboken/templates/airbrake.rb.tt', 'config/airbrake.rb')
      end

      def add_middleware
        indentation = classic? ? 2 : 6
        require_snippet = indent("require_relative 'airbrake'\n", indentation)
        middleware_snippet = indent("use Airbrake::Rack::Middleware\n", indentation)
        location = /configure :production do\n/

        insert_into_file('config/environment.rb', after: location) do
          "#{require_snippet}#{middleware_snippet}\n"
        end
      end

      # rubocop:disable Metrics/MethodLength
      def update_readme
        snippet = <<~CODE
          <tr>
              <td>AIRBRAKE_PROJECT_ID</td>
              <td>Production Only</td>
              <td>None</td>
              <td>Airbrake project ID. Refer to the project's settings page in Airbrake</td>
          </tr>
          <tr>
              <td>AIRBRAKE_PROJECT_KEY</td>
              <td>Production Only</td>
              <td>None</td>
              <td>Airbrake project key. Refer to the project's settings page in Airbrake</td>
          </tr>
        CODE

        insert_into_file('README.md', after: /<tbody>\n/) do
          indent(snippet, 8)
        end
      end
      # rubocop:enable Metrics/MethodLength

      def reminders
        text = <<~TEXT

          Gemfile updated... don't forget to 'bundle install'

          You can configure a Airbrake settings in `config/airbrake.rb`. By
          default Airbrake is set to only be used in production environments.
          Don't forget to set your `AIRBRAKE_PROJECT_ID` and `AIRBRAKE_PROJECT_KEY`.
        TEXT

        say text, :green
      end
    end
  end
end
