#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'json'
require 'wikidata/fetcher'

require 'pry'

WIKIDATA_SPARQL_URL = 'https://query.wikidata.org/sparql'

class Result
  def initialize(raw_hash)
    @raw = raw_hash
  end

  def method_missing(attr)
    return '' unless h = @raw[attr]
    return h[:value].to_s[0..9] if h[:datatype] == 'http://www.w3.org/2001/XMLSchema#dateTime'
    return '{{Q|%s}}' % [h[:value].to_s.split('/').last] if h[:type] == 'uri'
    h[:value]
  end
end

def sparql(query)
  result = RestClient.get WIKIDATA_SPARQL_URL, accept: 'application/sparql-results+json', params: { query: query }
  JSON.parse(result, symbolize_names: true)[:results][:bindings]
rescue RestClient::Exception => e
  raise "Wikidata query #{query} failed: #{e.message}"
end

query = <<EOQ
  SELECT DISTINCT ?ordinal ?item ?start_date ?end_date ?prev ?next WHERE {
    ?item wdt:P31 wd:Q5 ; p:P39 ?posn .
    ?posn ps:P39 wd:%s .
    OPTIONAL { ?posn pq:P580 ?start_date. }
    OPTIONAL { ?posn pq:P582 ?end_date. }
    OPTIONAL { ?posn pq:P1365|pq:P155 ?prev. }
    OPTIONAL { ?posn pq:P1366|pq:P156 ?next. }
    OPTIONAL { ?posn pq:P2715 ?election. }
    OPTIONAL { ?posn pq:P1545 ?ordinal. }
  }
  ORDER BY DESC(?start_date)
EOQ

qid = ARGV.first || abort("Usage: #{$PROGRAM_NAME} <Qid>")

json = sparql(query % qid)
data = json.map { |r| Result.new(r) }

puts '{| class="wikitable"'
puts '! ordinal !! person !! start date !! end date !! replaces !! replaced by'
puts data.map { |o| [o.ordinal, o.item, o.start_date, o.end_date, o.prev, o.next].join('||').prepend("|-\n|") }.join("\n")
puts '|}'
