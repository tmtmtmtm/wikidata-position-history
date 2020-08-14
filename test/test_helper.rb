# frozen_string_literal: true

require 'warning'

Gem.path.each do |path|
  Warning.ignore(//, path)
end

require 'minitest/autorun'
require 'pry'
require 'webmock/minitest'

require 'wikidata_position_history'

def example_data_path
  Pathname.new('test/example-data')
end

def fake_login
  stub_request(:post, 'https://www.wikidata.org/w/api.php')
    .with(body: hash_including({ 'action' => 'login' }))
    .to_return(status: 200, body: '{"login": { "result": "Success" }}')
end

def use_sample_data
  stub_request(:get, %r{query.wikidata.org/sparql}).to_return do |request|
    filename = request.uri.to_s[/ps:P39%20wd:(Q\d+)/, 1] + '.json'
    { body: (example_data_path + filename).read }
  end
end
