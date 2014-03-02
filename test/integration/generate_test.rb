require_relative "../test_helper"

class GenerateTest < IntegrationTestCase
  def test_generate_classic
    run_hoboken(:generate) do
      assert_file ".env"
      assert_file "Gemfile"
      assert_file "README.md"
      assert_file "Rakefile"
      assert_file "app.rb", /require "sinatra"/
      assert_file "config.ru", /run Sinatra::Application/
      assert_directory "public"
      assert_directory "test"
      assert_file "views/index.erb"
      assert_file "views/layout.erb"
    end
  end

  def test_generate_classic_tiny
    run_hoboken(:generate, tiny: true) do
      refute_directory("public")
      assert_file "app.rb", /__END__/, /@@layout/, /@@index/
    end
  end

  def test_generate_classic_can_run_tests
    run_hoboken(:generate) do
      assert_match /1 tests, 1 assertions, 0 failures, 0 errors, 0 skips/, execute("rake test:all")
    end
  end

  def test_generate_modular
    run_hoboken(:generate, type: :modular) do
      assert_file ".env"
      assert_file "Gemfile"
      assert_file "README.md"
      assert_file "Rakefile"
      assert_file "app.rb", /require "sinatra\/base"/, /module Sample/, /class App < Sinatra::Base/
      assert_file "config.ru", /run Sample::App/
      assert_directory "public"
      assert_file "test/test_helper.rb", /Sample::App/
      assert_file "views/index.erb"
      assert_file "views/layout.erb"
    end
  end

  def test_generate_modular_tiny
    run_hoboken(:generate, tiny: true, type: :modular) do
      refute_directory("public")
      assert_file "app.rb", /__END__/, /@@layout/, /@@index/
    end
  end

  def test_generate_modular_can_run_tests
    run_hoboken(:generate, type: :modular) do
      assert_match /1 tests, 1 assertions, 0 failures, 0 errors, 0 skips/, execute("rake test:all")
    end
  end

  def test_generate_with_ruby_version
    run_hoboken(:generate, ruby_version: "2.1.0") do
      assert_file "Gemfile", /ruby "2\.1\.0"/
    end
  end

  def test_generate_with_git
    run_hoboken(:generate, git: true) do
      assert_directory ".git"
    end
  end
end
