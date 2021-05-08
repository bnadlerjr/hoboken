# frozen_string_literal: true

require_relative '../test_helper'

class InternationalizationTest < IntegrationTestCase
  def test_internationalization_add_on_classic
    run_hoboken(:generate) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:i18n")
      assert_file('Gemfile', 'sinatra-r18n')
      assert_file('app.rb', "require 'sinatra/r18n'")
      assert_file('i18n/en.yml')
      assert_match(/no offenses detected/, execute('rubocop'))
    end
  end

  def test_internationalization_add_on_modular
    run_hoboken(:generate, type: :modular) do
      bin_path = File.expand_path('../../bin/hoboken', __dir__)
      execute("#{bin_path} add:i18n")
      assert_file('Gemfile', 'sinatra-r18n')
      assert_file('app.rb', "require 'sinatra/r18n'", 'register Sinatra::R18n')
      assert_file('i18n/en.yml')
      assert_match(/no offenses detected/, execute('rubocop'))
    end
  end
end
