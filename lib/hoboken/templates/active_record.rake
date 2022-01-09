# frozen_string_literal: true

require 'sinatra/activerecord/rake'

namespace :db do
  # rubocop:disable Rake/Desc
  task :load_config do
    require_relative '../config/environment'
  end
  # rubocop:enable Rake/Desc
end
