# frozen_string_literal: true

require_relative '../test_helper'

class AirbrakeTest < IntegrationTestCase
  def test_airbrake_add_on_with_classic
    run_hoboken(:generate) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:airbrake")
      assert_file('Gemfile', 'airbrake')
      assert_file('README.md', 'AIRBRAKE_PROJECT_ID')
      assert_file('README.md', 'AIRBRAKE_PROJECT_KEY')
      assert_file('config/airbrake.rb')
      assert_file('config/environment.rb', "require_relative 'airbrake'")
      assert_file('config/environment.rb', 'use Airbrake::Rack::Middleware')
    end
  end

  def test_airbrake_add_on_with_modular
    run_hoboken(:generate, type: :modular) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:airbrake")
      assert_file('Gemfile', 'airbrake')
      assert_file('README.md', 'AIRBRAKE_PROJECT_ID')
      assert_file('README.md', 'AIRBRAKE_PROJECT_KEY')
      assert_file('config/airbrake.rb')
      assert_file('config/environment.rb', "require_relative 'airbrake'")
      assert_file('config/environment.rb', 'use Airbrake::Rack::Middleware')
    end
  end
end
