require_relative "../test_helper"

class AddOnTest < IntegrationTestCase
  def test_metrics_add_on
    run_hoboken(:generate) do
      bin_path = File.expand_path("../../../bin/hoboken", __FILE__)
      execute("#{bin_path} add:metrics")
      assert_file("Gemfile", /flog/, /flay/, /simplecov/)
      assert_file("tasks/metrics.rake")
      assert_file("test/test_helper.rb",
<<CODE

require 'simplecov'
SimpleCov.start do
  add_filter "/test/"
  coverage_dir 'tmp/coverage'
end

CODE
                 )
    end
  end

  def test_internationalization_add_on_classic
    run_hoboken(:generate) do
      bin_path = File.expand_path("../../../bin/hoboken", __FILE__)
      execute("#{bin_path} add:i18n")
      assert_file("Gemfile", "sinatra-r18n")
      assert_file("app.rb", 'require "sinatra/r18n"')
      assert_file("i18n/en.yml")
    end
  end

  def test_internationalization_add_on_modular
    run_hoboken(:generate, type: :modular) do
      bin_path = File.expand_path("../../../bin/hoboken", __FILE__)
      execute("#{bin_path} add:i18n")
      assert_file("Gemfile", "sinatra-r18n")
      assert_file("app.rb", 'require "sinatra/r18n"', "register Sinatra::R18n")
      assert_file("i18n/en.yml")
    end
  end

  def test_heroku_add_on
    run_hoboken(:generate) do
      bin_path = File.expand_path("../../../bin/hoboken", __FILE__)
      execute("#{bin_path} add:heroku")
      assert_file("Gemfile", "foreman")
      assert_file("Procfile")
      assert_file(".slugignore")
      assert_file("config.ru", /\$stdout.sync = true/)
      assert_file("Rakefile", /exec\("foreman start"\)/)
    end
  end

  def test_sprockets_add_on_classic
    run_hoboken(:generate) do
      bin_path = File.expand_path("../../../bin/hoboken", __FILE__)
      execute("#{bin_path} add:sprockets")
      assert_file("assets/styles.css")
      assert_file("assets/app.js")
      assert_file("Gemfile", "sprockets", "uglifier", "yui-compressor")
      assert_file("tasks/sprockets.rake")
      assert_file("middleware/sprockets_chain.rb")
      assert_file("helpers/sprockets.rb")
      assert_file("app.rb", <<CODE
if development?
  require "sinatra/reloader"

  require File.expand_path('middleware/sprockets_chain', settings.root)
  use Middleware::SprocketsChain, %r{/assets} do |env|
    %w(assets vendor).each do |f|
      env.append_path File.expand_path("../\#{f}", __FILE__)
    end
  end
end

helpers Helpers::Sprockets
CODE
                 )
      assert_file("views/layout.erb", <<CODE
  <%= stylesheet_tag :styles %>

  <%= javascript_tag :app %>
CODE
                 )
    end
  end

  def test_sprockets_add_on_modular
    run_hoboken(:generate, type: :modular) do
      bin_path = File.expand_path("../../../bin/hoboken", __FILE__)
      execute("#{bin_path} add:sprockets")
      assert_file("assets/styles.css")
      assert_file("assets/app.js")
      assert_file("Gemfile", "sprockets", "uglifier", "yui-compressor")
      assert_file("tasks/sprockets.rake")
      assert_file("middleware/sprockets_chain.rb")
      assert_file("helpers/sprockets.rb")
      assert_file("app.rb", <<CODE
    configure :development do
      require File.expand_path('middleware/sprockets_chain', settings.root)
      use Middleware::SprocketsChain, %r{/assets} do |env|
        %w(assets vendor).each do |f|
          env.append_path File.expand_path("../\#{f}", __FILE__)
        end
      end
CODE
                 )
      assert_file("views/layout.erb", <<CODE
  <%= stylesheet_tag :styles %>

  <%= javascript_tag :app %>
CODE
                 )
    end
  end
end
