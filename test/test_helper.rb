# frozen_string_literal: true

require 'bundler/setup'

require 'warning'

# Ignore all warnings in Gem dependencies
Gem.path.each { |path| Warning.ignore(//, path) }

require 'test/unit'
require 'fileutils'

# rubocop:disable Style/GlobalVars
$hoboken_counter = 0
DESTINATION = File.expand_path('tmp', __dir__)
FileUtils.rm_rf(DESTINATION)

class IntegrationTestCase < Test::Unit::TestCase
  def teardown
    if passed?
      FileUtils.rm_rf("#{DESTINATION}/#{$hoboken_counter}")
    else
      puts "Left #{DESTINATION}/#{$hoboken_counter}/sample in place since test failed."
    end
  end

  def run_hoboken(command, **opts)
    options = extract_cli_options(opts)
    check_rubocop = opts.fetch(:rubocop, true)
    run_app_tests_or_specs = opts.fetch(:run_tests, true)

    $hoboken_counter += 1
    bin_path = File.expand_path('../bin/hoboken', __dir__)

    # rubocop:disable Layout/LineLength
    `#{bin_path} #{command} #{DESTINATION}/#{$hoboken_counter}/sample #{options.join(' ')}`
    # rubocop:enable Layout/LineLength
    yield

    assert_match(/0 failures/, execute('rake')) if run_app_tests_or_specs
    assert_match(/no offenses detected/, execute('rubocop')) if check_rubocop
  end

  def execute(command)
    FileUtils.cd("#{DESTINATION}/#{$hoboken_counter}/sample") do
      `#{command}`
    end
  end

  def assert_file(filename, *contents)
    full_path = File.join(DESTINATION, $hoboken_counter.to_s, 'sample', filename)
    assert_block("expected #{filename.inspect} to exist") do
      File.exist?(full_path)
    end

    return if contents.empty?

    read = File.read(full_path)
    contents.each do |content|
      assert_block("expected #{filename.inspect} to contain #{content}:\n#{read}") do
        pattern = content.is_a?(Regexp) ? content : Regexp.new(Regexp.quote(content))
        read =~ pattern
      end
    end
  end

  def assert_file_does_not_have_content(filename, *contents)
    full_path = File.join(DESTINATION, $hoboken_counter.to_s, 'sample', filename)
    assert_block("expected #{filename.inspect} to exist") do
      File.exist?(full_path)
    end

    read = File.read(full_path)
    contents.each do |content|
      assert_block("expected #{filename.inspect} to not contain #{content}:\n#{read}") do
        pattern = content.is_a?(Regexp) ? content : Regexp.new(Regexp.quote(content))
        read !~ pattern
      end
    end
  end

  def assert_directory(name)
    assert_block("expected #{name} directory to exist") do
      File.directory?(File.join(DESTINATION, $hoboken_counter.to_s, 'sample', name))
    end
  end

  def refute_directory(name)
    assert_block("did not expect directory #{name} to exist") do
      !File.directory?(File.join(DESTINATION, $hoboken_counter.to_s, 'sample', name))
    end
  end

  private

  # rubocop:disable Metrics/AbcSize
  def extract_cli_options(opts)
    [].tap do |o|
      o << '--git' if opts.fetch(:git, false)
      o << '--tiny' if opts.fetch(:tiny, false)
      o << '--api-only' if opts.fetch(:api_only, false)
      o << "--test_framework=#{opts[:test_framework]}" if opts.key?(:test_framework)
      o << "--type=#{opts[:type]}" if opts.key?(:type)
      o << "--ruby-version=#{opts[:ruby_version]}" if opts.key?(:ruby_version)
    end
  end
  # rubocop:enable Metrics/AbcSize
end
# rubocop:enable Style/GlobalVars
