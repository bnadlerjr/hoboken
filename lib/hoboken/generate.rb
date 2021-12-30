# frozen_string_literal: true

require 'rbconfig'

module Hoboken
  # Main project generator.
  #
  # rubocop:disable Metrics/ClassLength
  class Generate < Thor::Group
    include Thor::Actions

    NULL = RbConfig::CONFIG['host_os'].match?(/mingw|mswin/) ? 'NUL' : '/dev/null'

    argument :name

    class_option :ruby_version,
                 type: :string,
                 desc: 'Ruby version for Gemfile',
                 default: RUBY_VERSION

    class_option :tiny,
                 type: :boolean,
                 desc: 'Generate views inline; do not create /public folder',
                 default: false

    class_option :type,
                 type: :string,
                 desc: 'Architecture type (classic or modular)',
                 default: :classic

    class_option :git,
                 type: :boolean,
                 desc: 'Create a Git repository and make initial commit',
                 default: false

    class_option :api_only,
                 type: :boolean,
                 desc: 'API only, no views, public folder, etc.',
                 default: false

    class_option :test_framework,
                 type: :string,
                 desc: 'Testing framework; can be either test-unit or rspec',
                 default: 'test-unit'

    def self.source_root
      File.dirname(__FILE__)
    end

    def app_folder
      empty_directory(snake_name)
      apply_template('classic.rb.tt', 'app.rb')
      apply_template('Gemfile.erb.tt', 'Gemfile')
      apply_template('config.ru.tt', 'config.ru')
      apply_template('README.md.tt', 'README.md')
      apply_template('Rakefile.tt', 'Rakefile')

      create_file("#{snake_name}/Procfile") do
        'web: bundle exec puma -C config/puma.rb'
      end
    end

    def bin_folder
      empty_directory("#{snake_name}/bin")
      %w[console server setup].each do |f|
        target = "#{snake_name}/bin/#{f}"
        copy_file("templates/#{f}", target)
        chmod(target, 0o755)
      end
    end

    def config_folder
      empty_directory("#{snake_name}/config")
      apply_template('puma.rb.tt', 'config/puma.rb')
      apply_template('classic_environment.rb.tt', 'config/environment.rb')
    end

    def view_folder
      return if options[:api_only]

      empty_directory("#{snake_name}/views")
      apply_template('views/layout.erb.tt', 'views/layout.erb')
      apply_template('views/index.erb.tt', 'views/index.erb')
    end

    def asset_pipeline
      return if options[:api_only]

      inside snake_name do
        empty_directory('assets')
        empty_directory('public')
        %w[stylesheets images javascripts].each { |f| empty_directory("assets/#{f}") }
      end

      apply_template('styles.css.tt', 'assets/stylesheets/styles.scss')
      create_file("#{snake_name}/assets/javascripts/app.js", '')

      %w[favicon hoboken sinatra].each do |f|
        copy_file("templates/#{f}.png", "#{snake_name}/assets/images/#{f}.png")
      end
    end

    def test_folder
      return unless 'test-unit' == options[:test_framework]

      empty_directory("#{snake_name}/test/unit")
      empty_directory("#{snake_name}/test/integration")
      empty_directory("#{snake_name}/test/support")
      apply_template('test_unit.rake.tt', 'tasks/test_unit.rake')
      apply_template('test/test_helper.rb.tt', 'test/test_helper.rb')
      apply_template('test/unit/app_test.rb.tt', 'test/unit/app_test.rb')
      apply_template('support/rack_helpers.rb.tt', 'test/support/rack_helpers.rb')
      apply_template('support/rack_test_assertions.rb.tt',
                     'test/support/rack_test_assertions.rb')
    end

    def rspec_setup
      return unless 'rspec' == options[:test_framework]

      empty_directory("#{snake_name}/spec")
      empty_directory("#{snake_name}/spec/support")
      create_file("#{snake_name}/.rspec") { '--require spec_helper' }
      apply_template('rspec.rake.tt', 'tasks/rspec.rake')
      apply_template('spec/app_spec.rb.tt', 'spec/app_spec.rb')
      apply_template('spec/spec_helper.rb.tt', 'spec/spec_helper.rb')
      apply_template('support/rack_helpers.rb.tt', 'spec/support/rack_helpers.rb')
      apply_template('spec/rack_matchers.rb.tt', 'spec/support/rack_matchers.rb')
    end

    def env_file
      inside snake_name do
        create_file('.env') do
          "RACK_ENV=development\nPORT=9292\nSESSION_SECRET=secret"
        end
      end
    end

    # rubocop:disable Metrics/AbcSize
    def make_modular
      return unless 'modular' == options[:type]

      empty_directory("#{snake_name}/helpers")
      remove_file("#{snake_name}/app.rb")
      remove_file("#{snake_name}/config/environment.rb")
      apply_template('modular.rb.tt', 'app.rb')
      apply_template('modular_environment.rb.tt', 'config/environment.rb')

      files = [].tap do |f|
        f << 'config.ru'
        f << 'test/support/rack_helpers.rb' if 'test-unit' == options[:test_framework]
        f << 'spec/support/rack_helpers.rb' if 'rspec' == options[:test_framework]
      end

      files.each do |f|
        path = File.join(snake_name, f)
        gsub_file(path, /Sinatra::Application/, "#{camel_name}::App")
      end
    end
    # rubocop:enable Metrics/AbcSize

    def inline_views
      return unless options[:tiny]
      return if options[:api_only]

      combined_views = %w[layout index].map { |f|
        "@@#{f}\n" + File.read("#{snake_name}/views/#{f}.erb")
      }.join("\n")

      append_to_file("#{snake_name}/app.rb", "\n__END__\n\n#{combined_views}")
      remove_dir("#{snake_name}/views")
    end

    def create_git_repository
      return unless options[:git]

      if git?
        copy_file('templates/gitignore', "#{snake_name}/.gitignore")
        inside snake_name do
          run('git init .')
          run('git add .')
          run('git commit -m "Initial commit."')
        end
      else
        say "\nYou asked that a Git repository be created for the " \
            'project, but no Git executable could be found.'
      end
    end

    def directions
      say "\nSuccessfully created #{name}."
    end

    def self.exit_on_failure?
      true
    end

    private

    def snake_name
      Thor::Util.snake_case(name)
    end

    def camel_name
      Thor::Util.camel_case(name.split('/').last)
    end

    def titleized_name
      snake_name.split('_').map(&:capitalize).join(' ')
    end

    def author
      if git?
        `git config user.name`.chomp
      else
        say "\nNo Git executable found. Using result of `whoami` as author name."
        `whoami`.chomp
      end
    end

    def git?
      system("git --version >#{NULL} 2>&1")
    end

    def apply_template(src, dest)
      template("templates/#{src}", "#{snake_name}/#{dest}")
    end

    def ruby_three_one_or_greater?
      Gem::Version.new(RUBY_VERSION).release >= Gem::Version.new('3.1')
    end
  end
  # rubocop:enable Metrics/ClassLength
end
