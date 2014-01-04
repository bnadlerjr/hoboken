require "bundler/gem_tasks"
require "rake/testtask"

task :default => "test:unit"

namespace :test do
  Rake::TestTask.new(:unit) do |t|
    t.libs << 'test/unit'
    t.test_files = Dir["test/unit/**/*_test.rb"]
  end
end
