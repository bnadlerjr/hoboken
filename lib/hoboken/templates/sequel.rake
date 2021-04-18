# frozen_string_literal: true

namespace :db do
  require 'sequel'

  Sequel.extension :migration
  db = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://db/development.db')

  desc 'Migrate the database to latest version'
  task :migrate do
    Sequel::Migrator.run(db, 'db/migrate')
    puts '<= db:migrate executed'
  end

  desc 'Perform migration reset (full erase and migration up)'
  task :reset do
    Sequel::Migrator.run(db, 'db/migrate', target: 0)
    Sequel::Migrator.run(db, 'db/migrate')
    puts '<= db:reset executed'
  end
end
