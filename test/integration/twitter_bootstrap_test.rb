# frozen_string_literal: true

require_relative '../test_helper'

class TwitterBootstrapTest < IntegrationTestCase
  def test_twitter_bootstrap_add_on_classic
    run_hoboken(:generate) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      result = execute("#{bin_path} add:twbs")
      assert_match(/Gemfile updated/, result)

      assert_file('Gemfile', /bootstrap/)
      assert_file('config/environment.rb', /require 'bootstrap'/)
      assert_file('assets/stylesheets/styles.scss', /@import "bootstrap"/)
      assert_file('assets/javascripts/app.js', /require popper/)
      assert_file('assets/javascripts/app.js', /require bootstrap-sprockets/)
      assert_file_does_not_have_content('views/layout.erb', /normalize/)
      execute('bundle exec rake assets:precompile')
      assert_directory('public/assets')
    end
  end

  def test_twitter_bootstrap_add_on_modular
    run_hoboken(:generate, type: :modular) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      result = execute("#{bin_path} add:twbs")
      assert_match(/Gemfile updated/, result)

      assert_file('Gemfile', /bootstrap/)
      assert_file('config/environment.rb', /require 'bootstrap'/)
      assert_file('assets/stylesheets/styles.scss', /@import "bootstrap"/)
      assert_file('assets/javascripts/app.js', /require popper/)
      assert_file('assets/javascripts/app.js', /require bootstrap-sprockets/)
      assert_file_does_not_have_content('views/layout.erb', /normalize/)
      execute('bundle exec rake assets:precompile')
      assert_directory('public/assets')
    end
  end
end
