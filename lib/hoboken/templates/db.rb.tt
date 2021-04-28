# frozen_string_literal: true

if ENV['DATABASE_URL']
  require 'logger'
  require 'sequel'

  args = 'test' == ENV['RACK_ENV'] ? ['tmp/db_test.log', 'daily'] : [$stdout]
  DB = Sequel.connect(ENV['DATABASE_URL'], loggers: [Logger.new(*args)])
  Sequel.extension :migration

  unless Dir.glob('db/migrate/*.rb').empty?
    begin
      Sequel::Migrator.check_current(DB, 'db/migrate')
    rescue Sequel::Migrator::NotCurrentError
      puts 'Pending migrations detected... running migrations'
      Sequel::Migrator.run(DB, 'db/migrate')
      puts 'Database migrations completed'
    end
  end
  DB.freeze unless 'development' == ENV['RACK_ENV']
  puts 'Database connected'
else
  puts 'DATABASE_URL not set; skipping database initialization'
end
