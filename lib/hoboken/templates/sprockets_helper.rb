# frozen_string_literal: true

module Helpers
  # Sprockets view helpers.
  #
  module Sprockets
    def stylesheet_tag(name)
      folder = 'production' == ENV['RACK_ENV'] ? 'css' : 'assets'
      "<link href='/#{folder}/#{name}.css' rel='stylesheet' type='text/css' />"
    end

    def javascript_tag(name)
      folder = 'production' == ENV['RACK_ENV'] ? 'js' : 'assets'
      "<script type='text/javascript' src='/#{folder}/#{name}.js'></script>"
    end
  end
end
