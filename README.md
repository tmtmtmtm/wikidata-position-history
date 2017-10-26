# WikidataPositionHistory

Rewrites pages that include a `PositionHolderHistory` template
to include a timeline of people who have held a particular post,
including helpful diagnostics for common errors.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wikidata_position_history', github: 'everypolitician/wikidata-position-history'
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

This looks for a the first tag like:

```
{{PositionHolderHistory|id=Q14211}}
```

... in the page, and inserts after that tag wikitext that
renders to a list of people who have held (in a P39 sense) the
position Q14211. After that a sentinel HTML comment is insert,
so that on subsequent runs only the text between the template
and that comment are rewritten.

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
https://github.com/everypolitician/wikidata-position-history.

## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).
