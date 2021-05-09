# frozen_string_literal: true

require_relative '../test_helper'

class TwitterBootstrapTest < IntegrationTestCase
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def test_twitter_bootstrap_add_on_classic
    run_hoboken(:generate) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:sprockets")
      result = execute("#{bin_path} add:twbs")
      assert_match(/Gemfile updated/, result)

      assert_file('Gemfile', /bootstrap/)
      assert_file('config/environment.rb', /require 'bootstrap'/)
      assert_file('assets/styles.scss', /@import "bootstrap"/)
      assert_file('assets/app.js', /require popper/, /require bootstrap-sprockets/)
      assert_file('tasks/sprockets.rake', /require 'bootstrap'/)
      assert_file_does_not_have_content('views/layout.erb', /normalize/)

      assert_match(
        /successfully compiled css assets/,
        execute('rake assets:precompile_css')
      )

      assert_match(
        /successfully compiled javascript assets/,
        execute('rake assets:precompile_js')
      )

      assert_match(/no offenses detected/, execute('rubocop'))
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def test_twitter_bootstrap_add_on_modular
    run_hoboken(:generate, type: :modular) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:sprockets")
      result = execute("#{bin_path} add:twbs")
      assert_match(/Gemfile updated/, result)

      assert_file('Gemfile', /bootstrap/)
      assert_file('config/environment.rb', /require 'bootstrap'/)
      assert_file('assets/styles.scss', /@import "bootstrap"/)
      assert_file('assets/app.js', /require popper/, /require bootstrap-sprockets/)
      assert_file('tasks/sprockets.rake', /require 'bootstrap'/)
      assert_file_does_not_have_content('views/layout.erb', /normalize/)

      assert_match(
        /successfully compiled css assets/,
        execute('rake assets:precompile_css')
      )

      assert_match(
        /successfully compiled javascript assets/,
        execute('rake assets:precompile_js')
      )

      assert_match(/no offenses detected/, execute('rubocop'))
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def test_twitter_bootstrap_add_on_without_sprockets
    run_hoboken(:generate) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      result = execute("#{bin_path} add:twbs")
      assert_match(/Sprockets is required/, result)
    end
  end
end
