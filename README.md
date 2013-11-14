# Hoboken

Generate Sinatra project templates.

## Installation

    $ gem install hoboken

## Usage

To see a list of available commands:

    $ hoboken

Generating a new project:

    $ hoboken generate [appname] [options]

Options:
    --tiny
    --type [classic, modular]
    --ruby-version
    --middleware [name]
    --git

Generators for existing apps:

    $ hoboken add:sprockets
    $ hoboken add:bootstrap
    $ hoboken add:heroku
    $ hoboken add:i18n
    $ hoboken add:metrics
    $ hoboken add:middleware [name]

### Options

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
