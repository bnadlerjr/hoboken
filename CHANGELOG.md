# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
### Changed
### Removed
### Fixed

## [0.10.0] - 2022-01-17
### Added
* Add-on for Sidekiq.

* Add-on for Turnip.

* Add-on for VCR.

* Add-on for Airbrake.

* Add-on for `sinatra-activerecord`.

* Sinatra configuration block for test environment.

* More response codes for RSpec matchers / test unit assertions.

### Changed
* Define `SESSION_SECRET` in `.env` file so that it is defined only once and
  can be re-used by other things (like the Sidekiq UI).

* Switch `bin` scripts from bash to Ruby for consistency. Also fixes foreman
  errors w/ rerun gem by installing them separately from the bundle.

* Force https in production.

* Switch to `sinatra-asset-pipeline`. Remove Sprockets add-on. All non-API
  generated projects use `sinatra-asset-pipeline`.

* Various generated `README` improvements.

* `--api-only` apps don't get CSRF or cookie support.

* Sequel add-on now installs `rubocop-sequel` if Rubocop is detected.

* Simplecov from metrics add-on ignores `db/migrate` directory.

* RSpec and Rubocop Rake tasks are not loaded in production.

* Don't require a CSRF token when running in a test environment.

* Allow Rake in all environments.

* Enable performance plugin for Rubocop add-on by default.

* Database rollbacks now occur for all Rack-enabled test unit tests. For RSpec
  specs, they are enabled for all specs.

### Fixed
* Set proper application root for BetterErrors gem.

* CI task for RSpec projects.

* Rerun install in `setup` script needs `fs-event` gem.

## [0.9.0] - 2021-05-06
### Added
* `--api-only` option for core generator.

* Add-on for Twitter Bootstrap.

* Add-on for GitHub Action.

* Add-on for Rubocop.

* Added `pry-byebug` gem as part of the core generator.

* RSpec support. Add RSpec as an available `--test-framework` option.

* Console support via the `racksh` gem along with a Rake task for starting the
  console.

* BetterErrors gem as part of the core generator.

* `sinatra-flash` for all non-API projects.

* Rakefile gets a `ci` task that runs the installed test runner. If the Rubocop
  add-on is also detected, Rubocop will run after the tests.

### Changed
* Switch to Puma as default server instead of Thin. Add an explicit Puma
  config (`config/puma.rb`).

* Switched from sinatra-reloader to [rerun](https://github.com/alexch/rerun).

* Update all dependencies.

* Silence warnings from transitive gem dependencies in test output.

* Move generated Sequel DB setup out of `config.ru` and into its own
  file (`config/db.rb`).

* Dev server updates: always include a Procfile; create scripts for `setup`,
  `console`, `server`; server script uses foreman if it's available,
  otherwise rackup; remove Rake tasks for console, server.

* Use `sinatra-json` gem from `sinatra-contrib` instead of default JSON gem.

* Switch default templates to Erubi; escape HTML by default.

* Switch to `test-unit` gem.

* Generated `README` overhaul. Show environment variables in a table, bullet
  points showing default options and libraries installed, table of contents,
  etc.

### Fixed
* Don't attempt to add metrics snippets to non-existent files.

* `assert_redirected_to helper` argument.

* Hardcoded Omniauth route in generated tests.

## [0.1.0] - 2014-09-05
* Initial version

[Unreleased]: https://github.com/bnadlerjr/hoboken/compare/v0.10.0...HEAD
[0.10.0]: https://github.com/bnadlerjr/hoboken/compare/v0.9.0...v0.10.0
[0.9.0]: https://github.com/bnadlerjr/hoboken/compare/v0.0.1...v0.9.0
[0.0.1]: https://github.com/bnadlerjr/hoboken/releases/tag/v0.0.1
