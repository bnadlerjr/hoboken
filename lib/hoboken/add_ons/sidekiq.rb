# frozen_string_literal: true

module Hoboken
  module AddOns
    # Background processing via the Sidekiq gem.
    #
    class Sidekiq < ::Hoboken::Group
      def add_gems
        gem 'sidekiq', version: '6.2'
      end

      def adjust_rackup_config
        gsub_file('config.ru', /run .*::App.*\n/) do |match|
          <<~CODE
            require 'sidekiq/web'

            if 'production' == ENV.fetch('RACK_ENV', 'production')
              Sidekiq::Web.use Rack::Auth::Basic do |username, password|
                [username, password] == [ENV['SIDEKIQ_USERNAME'], ENV['SIDEKIQ_PASSWORD']]
              end
            end

            Sidekiq::Web.use Rack::Session::Cookie, secret: ENV['SESSION_SECRET']
            run Rack::URLMap.new('/' => #{match[4...-1].chomp}, '/sidekiq' => Sidekiq::Web)
          CODE
        end
      end

      def setup_config
        template('hoboken/templates/sidekiq.rb.tt', 'config/sidekiq.rb')
        location = "require_relative '../app'"
        insert_into_file('config/environment.rb', before: location) do
          "require_relative 'sidekiq'\n\n"
        end
      end

      def example_worker
        empty_directory('workers')
        template('hoboken/templates/example_worker.rb.tt', 'workers/example_worker.rb')
      end

      def worker_test_and_helper
        return if rspec?

        insert_into_file('test/test_helper.rb', after: "require 'rack/test'") do
          "\nrequire 'sidekiq/testing'"
        end

        template(
          'hoboken/templates/test/unit/example_worker_test.rb.tt',
          'test/unit/example_worker_test.rb'
        )
      end

      # rubocop:disable Metrics/MethodLength
      def worker_spec_and_helper
        return unless rspec?

        insert_into_file('spec/spec_helper.rb', after: "require 'rack/test'") do
          "\nrequire 'sidekiq/testing'"
        end

        snippet = <<~CODE
          config.before(:each, sidekiq: true) do
            Sidekiq::Worker.clear_all
          end
        CODE

        location = /RSpec\.configure do \|config\|\n/
        insert_into_file('spec/spec_helper.rb', after: location) do
          "#{indent(snippet, 2)}\n"
        end

        template(
          'hoboken/templates/spec/example_worker_spec.rb.tt',
          'spec/example_worker_spec.rb'
        )
      end
      # rubocop:enable Metrics/MethodLength

      def add_worker_to_procfile
        append_file('Procfile') do
          "\nworker: bundle exec sidekiq " \
            '-r ./config/sidekiq.rb ' \
            '-e $RACK_ENV ' \
            '-c ${MAX_THREADS:-5} ' \
            "-v\n"
        end
      end

      # rubocop:disable Metrics/MethodLength
      def update_readme
        snippet = <<~CODE
          <tr>
              <td>REDIS_URL</td>
              <td>Yes</td>
              <td>localhost:6379</td>
              <td>Redis connection URL</td>
          </tr>
          <tr>
              <td>SIDEKIQ_PASSWORD</td>
              <td>Production Only</td>
              <td>None</td>
              <td>Password for SidekiqUI Basic Auth</td>
          </tr>
          <tr>
              <td>SIDEKIQ_USERNAME</td>
              <td>Production Only</td>
              <td>None</td>
              <td>Username for SidekiqUI Basic Auth</td>
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

          You can configure a Sidekiq error handing service in `config/sidekiq.rb`.

          Sidekiq UI is available at '/sidekiq'. In production environments
          the UI is protected with HTTP Basic Auth. Don't forget to set
          `SIDEKIQ_USERNAME` and `SIDEKIQ_PASSWORD` in your production
          environment or you won't be able to access the Sidekiq UI.
        TEXT

        say text, :green
      end
    end
  end
end
