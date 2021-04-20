# frozen_string_literal: true

require 'rbconfig'

module Hoboken
  # Main project generator.
  #
  class Generate < Thor::Group
    include Thor::Actions

    NULL = RbConfig::CONFIG['host_os'] =~ /mingw|mswin/ ? 'NUL' : '/dev/null'

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

    def self.source_root
      File.dirname(__FILE__)
    end

    def app_folder
      empty_directory(snake_name)
      apply_template('classic.rb.tt',  'app.rb')
      apply_template('Gemfile.erb.tt', 'Gemfile')
      apply_template('config.ru.tt',   'config.ru')
      apply_template('README.md.tt',   'README.md')
      apply_template('Rakefile.tt',    'Rakefile')
    end

    def view_folder
      return if options[:api_only]

      empty_directory("#{snake_name}/views")
      apply_template('views/layout.erb.tt', 'views/layout.erb')
      apply_template('views/index.erb.tt', 'views/index.erb')
    end

    def public_folder
      return if options[:tiny] || options[:api_only]

      inside snake_name do
        empty_directory('public')
        %w[css img js].each { |f| empty_directory("public/#{f}") }
      end

      apply_template('styles.css.tt', 'public/css/styles.css')
      create_file("#{snake_name}/public/js/app.js", '')

      %w[favicon hoboken sinatra].each do |f|
        copy_file("templates/#{f}.png", "#{snake_name}/public/img/#{f}.png")
      end
    end

    def test_folder
      empty_directory("#{snake_name}/test/unit")
      empty_directory("#{snake_name}/test/integration")
      empty_directory("#{snake_name}/test/support")
      apply_template('test/test_helper.rb.tt', 'test/test_helper.rb')
      apply_template('test/unit/app_test.rb.tt', 'test/unit/app_test.rb')
      apply_template('test/support/rack_test_assertions.rb.tt',
                     'test/support/rack_test_assertions.rb')
    end

    def env_file
      inside snake_name do
        create_file('.env') do
          "RACK_ENV=development\nPORT=9292"
        end
      end
    end

    def make_modular
      return unless 'modular' == options[:type]

      empty_directory("#{snake_name}/helpers")
      remove_file("#{snake_name}/app.rb")
      apply_template('modular.rb.tt', 'app.rb')
      ['config.ru', 'test/test_helper.rb'].each do |f|
        path = File.join(snake_name, f)
        gsub_file(path, /Sinatra::Application/, "#{camel_name}::App")
      end
    end

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
          run('git commit -m \"Initial commit.\"')
        end
      else
        say "\nYou asked that a Git repository be created for the " \
          'project, but no Git executable could be found.'
      end
    end

    def directions
      if options[:api_only]
        say "\nAPI only projects should specify a JSON library to use for\n" \
            "emitting and parsing JSON. The MultiJson[1] gem has been\n" \
            "included in the Gemfile so that you can choose your JSON\n" \
            "engine. See the MultiJSON docs for more information.\n"

        say "\n[1]: https://github.com/intridea/multi_json"
      end
      say "\nSuccessfully created #{name}. Don't forget to `bundle install`"
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
  end
end
