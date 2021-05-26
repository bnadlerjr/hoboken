# frozen_string_literal: true

module Hoboken
  module AddOns
    # Gherkin extension for RSpec
    #
    class Turnip < ::Hoboken::Group
      def add_gems
        return unless rspec?

        gem 'turnip', version: '4.3', group: :test
      end

      # rubocop:disable Metrics/MethodLength
      def add_sample_files
        return unless rspec?

        empty_directory('spec/features')
        empty_directory('spec/support/steps')
        create_file('spec/features/example.feature') do
          <<~TEXT
            @feature
            Feature: An Example
                This is an example feature spec that can be deleted.

                Scenario: Name of some scenario
                    Given nothing
                    When I do nothing
                    Then nothing should happen
          TEXT
        end

        create_file('spec/support/steps/example_steps.rb') do
          <<~CODE
            # frozen_string_literal: true

            # Steps for the example feature that can be deleted.

            step 'nothing' do
              # ...
            end

            step 'I do nothing' do
              # ...
            end

            step 'nothing should happen' do
              # ...
            end
          CODE
        end
      end
      # rubocop:enable Metrics/MethodLength

      def add_helper
        return unless rspec?

        template(
          'hoboken/templates/spec/turnip_helper.rb.tt',
          'spec/turnip_helper.rb'
        )
      end

      def rake_task
        return unless rspec?

        create_file('tasks/turnip.rake') do
          <<~TEXT
            # frozen_string_literal: true

            desc 'Run turnip acceptance tests'
            RSpec::Core::RakeTask.new(:turnip) do |t|
              t.pattern = './spec{,/*/**}/*.feature'
              t.rspec_opts = ['-r turnip/rspec']
            end
          TEXT
        end
      end

      def default_rake_task
        return unless rspec?

        gsub_file('Rakefile', /task default:.*/, 'task default: %w[spec turnip]')
      end

      def ci_task
        return unless rspec?

        gsub_file('Rakefile', /task ci:.*/) do |match|
          if match.include?('rubocop')
            'task ci: %w[spec turnip rubocop]'
          else
            'task ci: %w[spec turnip]'
          end
        end
      end

      def reminders
        if rspec?
          say "Gemfile updated... don't forget to 'bundle install'", :green
        else
          say 'Turnip requires RSpec to be setup', :red
        end
      end
    end
  end
end
