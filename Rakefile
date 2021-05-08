# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'

RuboCop::RakeTask.new

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = Dir['test/**/*_test.rb']
end

task default: 'test'

desc 'Run CI checks'
task ci: %w[test rubocop]
