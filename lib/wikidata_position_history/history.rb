# encoding: utf-8
# frozen_string_literal: true

require 'json'
require 'rest-client'

WIKIDATA_SPARQL_URL = 'https://query.wikidata.org/sparql'

module WikidataPositionHistory
  class Query
    WIKIDATA_SPARQL_URL = 'https://query.wikidata.org/sparql'

    def initialize(query)
      @query = query
    end

    def results
      json
    rescue RestClient::Exception => e
      raise "Wikidata query #{query} failed: #{e.message}"
    end

    private

    attr_reader :query

    def result
      @result ||= RestClient.get WIKIDATA_SPARQL_URL, accept: 'application/sparql-results+json', params: { query: query }
    end

    def json
      JSON.parse(result, symbolize_names: true)[:results][:bindings]
    end
  end

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
      expected = expected_fields
      missing = expected.keys.reject { |i| current.send(i) }
      return unless missing.any?

      ["Missing field#{missing.count > 1 ? 's' : ''}", "#{current.item} is missing #{missing.map { |i| "{{P|#{expected[i]}}}" }.join(', ')}"]
    end

    def wrong_predecessor
      return unless earlier
      return unless current.prev && earlier.item
      return unless current.prev != earlier.item

      ['Inconsistent predecessor', "#{current.item} has a {{P|1365}} of #{current.prev}, which differs from #{earlier.item}"]
    end

    def wrong_successor
      return unless later
      return unless current.next && later.item
      return unless current.next != later.item

      ['Inconsistent sucessor', "#{current.item} has a {{P|1366}} of #{current.next}, which differs from #{later.item}"]
    end

    def ends_after_successor_starts
      return unless later
      return unless current.end_date && later.start_date
      return unless current.end_date > later.start_date

      ['Date overlap', "#{current.item} has a {{P|582}} of #{current.end_date}, which is later than {{P|580}} of #{later.start_date} for #{later.item}"]
    end

    private

    attr_reader :later, :current, :earlier

    def expected_fields
      expected = { start_date: 580 }
      expected[:prev] = 1365 if earlier
      expected[:end_date] = 582 if later
      expected[:next] = 1366 if later
      expected
    end
  end

  class Output
    def initialize(subject_item_id)
      @subject_item_id = subject_item_id
    end

    attr_reader :subject_item_id

    def warning(check, method)
      errors = check.send(method) or return ''
      '<span style="display: block">[[File:Pictogram voting comment.svg|15px|link=]]&nbsp;<span style="color: #d33; font-weight: bold; vertical-align: middle;">%s</span>&nbsp;<ref>%s</ref></span>' % [errors.first, errors.last]
    end

    def query
      <<~SPARQL
        SELECT DISTINCT ?ordinal ?item ?start_date ?end_date ?prev ?next WHERE {
          ?item wdt:P31 wd:Q5 ; p:P39 ?posn .
          ?posn ps:P39 wd:%s .
          FILTER NOT EXISTS { ?posn wikibase:rank wikibase:DeprecatedRank }

          OPTIONAL { ?posn pq:P580 ?start_date. }
          OPTIONAL { ?posn pq:P582 ?end_date. }
          OPTIONAL { ?posn pq:P1365|pq:P155 ?prev. }
          OPTIONAL { ?posn pq:P1366|pq:P156 ?next. }
          OPTIONAL { ?posn pq:P2715 ?election. }
          OPTIONAL { ?posn pq:P1545 ?ordinal. }
        }
        ORDER BY DESC(?start_date)
      SPARQL
    end

    def wikitext
      lines = []
      lines << '{| class="wikitable" style="text-align: center; border: none;"'

      padded_results.each_cons(3) do |later, current, earlier|
        next unless current
        check = Check.new(later, current, earlier)
        lines << '|-'
        lines << '| style="padding:0.5em 2em" | %s' % [current.ordinal ? "#{current.ordinal}." : '']
        lines << '| style="padding:0.5em 2em" | <span style="font-size: 1.5em; display: block;">%s</span> %s' % [
          current.item, (current.start_date || current.end_date ? "#{current.start_date} – #{current.end_date}" : ''),
        ]
        lines << '| style="padding:0.5em 2em 0.5em 1em; border: none; background: #fff; text-align: left;" | %s' % [
          warning(check, :missing_fields) +
          warning(check, :wrong_predecessor) +
          warning(check, :wrong_successor) +
          warning(check, :ends_after_successor_starts)
        ]
      end
      lines << "|}\n"
      lines.join("\n")
    end

    def wikitext_with_header
      ("== {{Q|%s}} officeholders ==\n" % subject_item_id) + wikitext
    end

    private

    def json
      @json ||= Query.new(query % subject_item_id).results
    end

    def results
      json.map { |r| Result.new(r) }
    end

    def padded_results
      [nil, results, nil].flatten(1)
    end
  end
end
