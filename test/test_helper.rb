# frozen_string_literal: true

require 'warning'

Gem.path.each do |path|
  Warning.ignore(//, path)
end

ENV['WIKI_USERNAME'] = 'test'
ENV['WIKI_PASSWORD'] = 'test'

require 'minitest/autorun'
require 'pry'
require 'webmock/minitest'

require 'wikidata_position_history'

def cached_mandates_path
  Pathname.new('test/example-data/mandates')
end

def cached_metadata_path
  Pathname.new('test/example-data/metadata')
end

def fake_login
  stub_request(:post, 'https://www.wikidata.org/w/api.php')
    .with(body: hash_including({ 'action' => 'login' }))
    .to_return(status: 200, body: '{"login": { "result": "Success" }}')
end

def use_sample_data
  stub_request(:get, %r{query.wikidata.org/sparql.*position-mandates}).to_return do |request|
    filename = request.uri.to_s[/ps:P39%20wd:(Q\d+)/, 1]
    { body: (cached_mandates_path + filename).sub_ext('.json').read }
  end

  stub_request(:get, %r{query.wikidata.org/sparql.*position-metadata}).to_return do |request|
    filename = request.uri.to_s[/wd:(Q\d+)/, 1]
    { body: (cached_metadata_path + filename).sub_ext('.json').read }
  end
end
