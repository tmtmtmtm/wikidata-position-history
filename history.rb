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
    return unless h = @raw[attr]
    return h[:value].to_s[0..9] if h[:datatype] == 'http://www.w3.org/2001/XMLSchema#dateTime'
    return '{{Q|%s}}' % [h[:value].to_s.split('/').last] if h[:type] == 'uri'
    h[:value]
  end
end

class Check
  def initialize(later, current, earlier)
    @later = later
    @current = current
    @earlier = earlier
  end

  def ends_after_successor_starts
    return unless later && later.start_date
    return '{{P|580}} is missing' unless current.end_date
    return "{{P|580}} of #{current.end_date} is later than start date of #{later.item} (#{later.start_date})" if current.end_date > later.start_date
  end

  def wrong_predecessor
    return unless earlier
    return '{{P|1365}} is missing' unless current.prev
    return "{{P|1365}} of #{current.prev} differs from predecessor (#{earlier.item})" if current.prev != earlier.item
  end

  def wrong_successor
    return unless later
    return '{{P|1366}} is missing' unless current.next
    return "{{P|1366}} of #{current.next} differs from successor (#{later.item})" if current.next != later.item
  end

  private

  attr_reader :later, :current, :earlier
end

def sparql(query)
  result = RestClient.get WIKIDATA_SPARQL_URL, accept: 'application/sparql-results+json', params: { query: query }
  JSON.parse(result, symbolize_names: true)[:results][:bindings]
rescue RestClient::Exception => e
  raise "Wikidata query #{query} failed: #{e.message}"
end

def cell(item, field, warning)
  footnote = " <ref>Warning for #{item.item}: #{warning}</ref>" if warning
  "|#{item.send(field)}#{footnote}"
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
list = [nil, data, nil].flatten(1)

puts '{| class="wikitable"'
puts '! ordinal !! person !! start date !! end date !! replaces !! replaced by'

list.each_cons(3) do |later, current, earlier|
  next unless current
  check = Check.new(later, current, earlier)
  puts '|-'
  puts cell(current, :ordinal, nil)
  puts cell(current, :item, nil)
  puts cell(current, :start_date, nil)
  puts cell(current, :end_date, check.ends_after_successor_starts)
  puts cell(current, :prev, check.wrong_predecessor)
  puts cell(current, :next, check.wrong_successor)
end
puts '|}'
