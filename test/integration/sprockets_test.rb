# frozen_string_literal: true

require_relative '../test_helper'

class SprocketsTest < IntegrationTestCase
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def test_sprockets_add_on_classic
    run_hoboken(:generate) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:sprockets")
      assert_file('assets/styles.scss')
      assert_file('assets/app.js')
      assert_file('Gemfile', 'sassc', 'sprockets', 'uglifier', 'yui-compressor')
      assert_file('tasks/sprockets.rake')
      assert_file('middleware/sprockets_chain.rb')
      assert_file('helpers/sprockets.rb')

      assert_file('config/environment.rb', <<CODE
  require File.expand_path('middleware/sprockets_chain', settings.root)
  use Middleware::SprocketsChain, %r{/assets} do |env|
    %w[assets vendor].each do |f|
      env.append_path File.expand_path("../\#{f}", __FILE__)
    end
  end
CODE
      )

      assert_file('config/environment.rb', /helpers Helpers::Sprockets/)
      assert_file('views/layout.erb', <<CODE
  <%== stylesheet_tag :styles %>
  <%== javascript_tag :app %>
CODE
      )

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
  def test_sprockets_add_on_modular
    run_hoboken(:generate, type: :modular) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:sprockets")
      assert_file('assets/styles.scss')
      assert_file('assets/app.js')
      assert_file('Gemfile', 'sassc', 'sprockets', 'uglifier', 'yui-compressor')
      assert_file('tasks/sprockets.rake')
      assert_file('middleware/sprockets_chain.rb')
      assert_file('helpers/sprockets.rb')

      assert_file('config/environment.rb', <<CODE
    configure :development do
      require File.expand_path('middleware/sprockets_chain', settings.root)
      use Middleware::SprocketsChain, %r{/assets} do |env|
        %w[assets vendor].each do |f|
          env.append_path File.expand_path("../\#{f}", __FILE__)
        end
      end
CODE
      )

      assert_file('views/layout.erb', <<CODE
  <%== stylesheet_tag :styles %>
  <%== javascript_tag :app %>
CODE
      )

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
end
