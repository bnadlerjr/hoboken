require "test/unit"
require "fileutils"

class GenerateTest < Test::Unit::TestCase
  attr_reader :bin_path, :destination_path

  def setup
    @destination_path = File.expand_path("../../output", __FILE__)
    @bin_path = File.expand_path("../../../bin/hoboken", __FILE__)
  end

  def teardown
    FileUtils.rm_rf(destination_path)
  end

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

  def test_generate_classic_can_run_tests
    run_hoboken(:generate) do
      assert_match /1 tests, 1 assertions, 0 failures, 0 errors, 0 skips/, execute("rake test:all")
    end
  end

  def run_hoboken(command, **opts)
    options = Array.new.tap do |o|
      o << "--git" if opts.fetch(:git) { false }
      o << "--tiny" if opts.fetch(:tiny) { false }
      o << "--ruby-version=#{opts[:ruby_version]}" if opts.has_key?(:ruby_version)
    end
    `#{bin_path} #{command} #{destination_path}/sample_1 #{options.join(" ")}`
    yield
  end

  def execute(command)
    current_path = Dir.pwd
    FileUtils.cd("#{destination_path}/sample_1")
    `bundle install` unless File.exists?("Gemfile.lock")
    `#{command}`
  ensure
    FileUtils.cd(current_path)
  end

  def assert_file(filename, *contents)
    full_path = File.join(destination_path, "sample_1", filename)
    assert_block("expected #{filename.inspect} to exist") do
      File.exists?(full_path)
    end

    unless contents.empty?
      read = File.read(full_path)
      contents.each do |content|
        assert_block("expected #{filename.inspect} to contain #{content}") do
          read =~ content
        end
      end
    end
  end

  def assert_directory(name)
    assert_block("expected #{name} directory to exist") do
      File.directory?(File.join(destination_path, "sample_1", name))
    end
  end

  def refute_directory(name)
    assert_block("did not expect directory #{name} to exist") do
      !File.directory?(File.join(destination_path, "sample_1", name))
    end
  end
end
