# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

task default: 'test:all'

namespace :test do
  types = %w[unit integration]

  types.each do |type|
    Rake::TestTask.new(type.to_sym) do |t|
      t.libs << "test/#{type}"
      t.test_files = Dir["test/#{type}/**/*_test.rb"]
    end
  end

  desc 'Run all tests'
  task all: types.map { |s| "test:#{s}" }
end
