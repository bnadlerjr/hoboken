# Project Ideas

## New Directory Structure

General idea is similar to Hexagonal or Ports and Adapters architecture. Web
and DB concerns depend on the application core, not the other way around.

/web -- depends on --> /db
/web -- depends on --> /lib
/db  -- depends on --> /lib
/lib -- depends on --> nothing from from /web or /db

```
Gemfile
Gemfile.lock
README.md
Rakefile
config.ru
app.rb
db.rb
/config
    db.rb
    environment.rb
    puma.rb
/db
    /mappers
        some_mapper.rb
    /migrate
        migration_001.rb
    sequel_mapper.rb
/lib
    <project_name>.rb
    /<project_name>
        ... files
/helpers
    some_helper.rb
/public
    /css
        styles.css
    /img
        favicon.png
        hoboken.png
        sinatra.png
    /js
        app.js
/views
    index.erb
    layout.erb
/test
    test_helper.rb
    /<project_name>
    /db
        some_mapper_test.rb
    /support
        rack_test_assertions.rb
    app_test.rb
```
