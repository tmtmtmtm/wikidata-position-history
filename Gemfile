# frozen_string_literal: true

# It's easy to add more libraries or choose different versions. Any libraries
# specified here will be installed and made available to your morph.io scraper.
# Find out more: https://morph.io/documentation/ruby

ruby '2.3.3'

source 'https://rubygems.org'
git_source(:github) { |repo_name| "https://github.com/#{repo_name}.git" }

gem 'activesupport-inflector'
gem 'colorize'
gem 'everypolitician', github: 'everypolitician/everypolitician-ruby'
gem 'i18n'
gem 'mediawiki_api'
gem 'nokogiri'
gem 'open-uri-cached'
gem 'pry'
gem 'rest-client'
gem 'scraperwiki', github: 'openaustralia/scraperwiki-ruby',
                   branch: 'morph_defaults'
gem 'sqlite_magic', github: 'openc/sqlite_magic'
gem 'wikidata-fetcher', '>=0.20.0', github: 'everypolitician/wikidata-fetcher'
gem 'wikisnakker', github: 'everypolitician/wikisnakker'

group :quality do
  gem 'rubocop'
end
