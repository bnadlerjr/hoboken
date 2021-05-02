# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :assets do
  require 'sprockets'
  require 'uglifier'
  require 'yui/compressor'
  sprockets = Sprockets::Environment.new { |env| env.logger = Logger.new($stdout) }
  sprockets.css_compressor = YUI::CssCompressor.new
  sprockets.js_compressor = Uglifier.new(harmony: true)

  %w[assets vendor].each do |f|
    sprockets.append_path File.expand_path("../../#{f}", __FILE__)
  end

  output_path = File.expand_path('../public', __dir__)

  desc 'Pre-compile CSS assets'
  task :precompile_css do
    asset = sprockets['styles.css']
    outfile = Pathname.new(output_path).join('css/styles.css')
    FileUtils.mkdir_p outfile.dirname
    asset.write_to(outfile)
    puts 'successfully compiled css assets'
  end

  desc 'Pre-compile JavaScript assets'
  task :precompile_js do
    asset = sprockets['app.js']
    outfile = Pathname.new(output_path).join('js/app.js')
    FileUtils.mkdir_p outfile.dirname
    asset.write_to(outfile)
    puts 'successfully compiled javascript assets'
  end

  desc 'precompile all assets'
  task precompile: %i[precompile_css precompile_js]
end
# rubocop:enable Metrics/BlockLength
