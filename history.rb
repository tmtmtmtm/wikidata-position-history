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

  def missing_fields
    expected = { start_date: 580 }
    expected[:prev] = 1365 if earlier
    if later
      expected[:end_date] = 582
      expected[:next] = 1366
    end
    missing = expected.keys.reject { |i| current.send(i) }
    return unless missing.any?
    ["Missing field#{missing.count > 1 ? 's' : ''}", "#{current.item} is missing #{missing.map { |i| "{{P|#{expected[i]}}}" }.join(', ')}"]
  end

  def ends_after_successor_starts
    return unless current.end_date && later&.start_date
    return ['Date overlap', "#{current.item} has a {{P|582}} of #{current.end_date}, which is later than {{P|580}} of #{later.start_date} for #{later.item}"] if current.end_date > later.start_date
  end

  def wrong_predecessor
    return unless current.prev && earlier&.item
    return ['Inconsistent predecessor', "#{current.item} has a {{P|1365}} of #{current.prev}, which differs from #{earlier.item}"] if current.prev != earlier.item
  end

  def wrong_successor
    return unless current.next && later&.item
    return ['Inconsistent sucessor', "#{current.item} has a {{P|1366}} of #{current.next}, which differs from #{later.item}"] if current.next != later.item
  end

  attr_reader :later, :current, :earlier
end

def sparql(query)
  result = RestClient.get WIKIDATA_SPARQL_URL, accept: 'application/sparql-results+json', params: { query: query }
  JSON.parse(result, symbolize_names: true)[:results][:bindings]
rescue RestClient::Exception => e
  raise "Wikidata query #{query} failed: #{e.message}"
end

def warning(check, method)
  errors = check.send(method) or return ''
  '<span style="display: block">[[File:Pictogram voting comment.svg|15px|link=]]&nbsp;<span style="color: #d33; font-weight: bold; vertical-align: middle;">%s</span>&nbsp;<ref>%s</ref></span>' % [errors.first, errors.last]
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

puts '{| class="wikitable" style="text-align: center;"'
list.each_cons(3) do |later, current, earlier|
  next unless current
  check = Check.new(later, current, earlier)
  puts '|-'
  puts '| style="padding:1em" | %s' % [current.ordinal ? "#{current.ordinal}." : '']
  puts '| style="padding:1em" | <span style="font-size: 1.5em; display: block;">%s</span> %s %s' % [
    current.item, (current.start_date || current.end_date ? "#{current.start_date}–#{current.end_date}" : ''),
    warning(check, :missing_fields) + warning(check, :wrong_predecessor) + warning(check, :wrong_successor) + warning(check, :ends_after_successor_starts),
  ]
end
puts '|}'
