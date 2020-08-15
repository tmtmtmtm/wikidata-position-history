# WikidataPositionHistory

Rewrites Mediawiki pages that include a `PositionHolderHistory`
template, to show a timeline of people who have held a particular
office, along with helpful diagnostic warnings for common errors.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wikidata_position_history', github: 'tmtmtmtm/wikidata-position-history'
```

And then execute:

    $ bundle

## Usage

```ruby
WikidataPositionHistory::PageRewriter.new(
   mediawiki_site: 'www.wikidata.org',
   page_title: 'User:Mhl20/Prime_minister_test'
).run!
```

This looks for a Template call in that page of the form:

```
{{PositionHolderHistory|id=Q14211}}
```

If such a template is found, a table is inserted after it listing all
people who have held (i.e. have a relevant P39 "position held"
statement) position Q14211.

A sentinel HTML comment is also inserted, so that on subsequent runs
only the text between the template and that comment are rewritten.

## Development

After checking out the repo, run `bin/setup` to install
dependencies. Then, run `rake test` to run the tests. You can
also run `bin/console` for an interactive prompt that will allow
you to experiment.

To install this gem onto your local machine, run `bundle exec
rake install`. To release a new version, update the version
number in `version.rb`, and then run `bundle exec rake release`,
which will create a git tag for the version, push git commits
and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/tmtmtmtm/wikidata-position-history

## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).

## History

This was originally developed by Tony Bowden and Mark Longair at
mySociety as part of a [Wikimedia Foundation grant-funded
project](https://meta.wikimedia.org/wiki/Grants:Project/mySociety/EveryPolitician).

This version is now maintained independently by Tony Bowden.
