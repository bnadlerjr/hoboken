# frozen_string_literal: true

require_relative '../test_helper'

class HerokuTest < IntegrationTestCase
  def test_heroku_add_on
    run_hoboken(:generate) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:heroku")
      assert_file('.slugignore')
      assert_file('config.ru', /\$stdout.sync = true/)
      assert_match(/no offenses detected/, execute('rubocop'))
    end
  end
end
