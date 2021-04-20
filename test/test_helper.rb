# frozen_string_literal: true

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

  # rubocop:disable Metrics/AbcSize
  def run_hoboken(command, **opts)
    options = [].tap do |o|
      o << '--git' if opts.fetch(:git, false)
      o << '--tiny' if opts.fetch(:tiny, false)
      o << '--api-only' if opts.fetch(:api_only, false)
      o << "--type=#{opts[:type]}" if opts.key?(:type)
      o << "--ruby-version=#{opts[:ruby_version]}" if opts.key?(:ruby_version)
    end

    $hoboken_counter += 1
    bin_path = File.expand_path('../bin/hoboken', __dir__)

    # rubocop:disable Layout/LineLength
    `#{bin_path} #{command} #{DESTINATION}/#{$hoboken_counter}/sample #{options.join(' ')}`
    # rubocop:enable Layout/LineLength
    yield
  end
  # rubocop:enable Metrics/AbcSize

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
end
# rubocop:enable Style/GlobalVars
