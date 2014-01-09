namespace :db do
  require 'sequel'

  Sequel.extension :migration
  DB = Sequel.connect(ENV['DATABASE_URL'] || "sqlite://db/development.db")

  desc 'Migrate the database to latest version'
  task :migrate do
    Sequel::Migrator.run(DB, 'db/migrate')
    puts '<= db:migrate executed'
  end

  desc 'Perform migration reset (full erase and migration up)'
  task :reset do
    Sequel::Migrator.run(DB, 'db/migrate', :target => 0)
    Sequel::Migrator.run(DB, 'db/migrate')
    puts '<= db:reset executed'
  end
end
