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

    def acting?
      nature.to_s.include? 'Q4676846'
    end
  end

  class Check
    def initialize(later, current, earlier)
      @later = later
      @current = current
      @earlier = earlier
    end

    def missing_fields
      missing = expected.reject { |i| current.send(i) }
      return unless missing.any?

      ["Missing field#{missing.count > 1 ? 's' : ''}", "#{current.item} is missing #{missing.map { |i| "{{P|#{field_map[i]}}}" }.join(', ')}"]
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

    def field_map
      {
        start_date: 580,
        prev:       1365,
        end_date:   582,
        next:       1366,
      }
    end

    def expected
      field_map.keys.select { |field| send("expect_#{field}?") }
    end

    def expect_start_date?
      true
    end

    def expect_end_date?
      later
    end

    def expect_prev?
      return unless earlier
      return if earlier.item == current.item # sucessive terms by same person

      !current.acting?
    end

    def expect_next?
      return unless later
      return if later.item == current.item # sucessive terms by same person

      !current.acting?
    end
  end

  class ItemOutput
    def initialize(current, check)
      @current = current
      @check = check
    end

    def output
      [row_start, ordinal_cell, member_cell, warnings_cell].join("\n")
    end

    private

    attr_reader :current, :check

    def warning(check, method)
      errors = check.send(method) or return ''
      '<span style="display: block">[[File:Pictogram voting comment.svg|15px|link=]]&nbsp;<span style="color: #d33; font-weight: bold; vertical-align: middle;">%s</span>&nbsp;<ref>%s</ref></span>' % [errors.first, errors.last]
    end

    def row_start
      '|-'
    end

    def ordinal_cell
      '| style="padding:0.5em 2em" | %s' % [current.ordinal ? "#{current.ordinal}." : '']
    end

    def member_style
      return 'font-size: 1.25em; display: block; font-style: italic;' if current.acting?

      'font-size: 1.5em; display: block;'
    end

    def member_cell
      '| style="padding:0.5em 2em" | <span style="%s">%s</span> %s' %
        [member_style, membership_person, membership_dates]
    end

    def warnings_cell
      '| style="padding:0.5em 2em 0.5em 1em; border: none; background: #fff; text-align: left;" | %s' %
        warning(check, :missing_fields) +
        warning(check, :wrong_predecessor) +
        warning(check, :wrong_successor) +
        warning(check, :ends_after_successor_starts)
    end

    def membership_person
      current.item
    end

    def membership_dates
      return '' unless current.start_date || current.end_date

      "#{current.start_date} – #{current.end_date}"
    end
  end

  class Output
    def initialize(subject_item_id)
      @subject_item_id = subject_item_id
    end

    attr_reader :subject_item_id

    def wikitext
      return no_items_output if results.empty?

      [table_header, table_rows, table_footer].compact.join("\n")
    end

    def wikitext_with_header
      ("== {{Q|%s}} officeholders ==\n" % subject_item_id) + wikitext
    end

    private

    def json
      @json ||= Query.new(sparql).results
    end

    def results
      json.map { |r| Result.new(r) }
    end

    def padded_results
      [nil, results, nil].flatten(1)
    end

    def no_items_output
      "\n{{PositionHolderHistory/error_no_holders|id=#{subject_item_id}}}\n"
    end

    def raw_sparql
      <<~SPARQL
        SELECT DISTINCT ?ordinal ?item ?start_date ?end_date ?prev ?next ?nature 
        WHERE {
          ?item wdt:P31 wd:Q5 ; p:P39 ?posn .
          ?posn ps:P39 wd:%s .
          FILTER NOT EXISTS { ?posn wikibase:rank wikibase:DeprecatedRank }

          OPTIONAL { ?posn pq:P580 ?start_date }
          OPTIONAL { ?posn pq:P582 ?end_date }
          OPTIONAL { ?posn pq:P1365|pq:P155 ?prev }
          OPTIONAL { ?posn pq:P1366|pq:P156 ?next }
          OPTIONAL { ?posn pq:P1545 ?ordinal }
          OPTIONAL { ?posn pq:P5102 ?nature }
        }
        ORDER BY DESC(?start_date)
      SPARQL
    end

    def table_header
      '{| class="wikitable" style="text-align: center; border: none;"'
    end

    def table_footer
      "|}\n"
    end

    def table_rows
      padded_results.each_cons(3).map do |later, current, earlier|
        next unless current

        check = Check.new(later, current, earlier)
        ItemOutput.new(current, check).output
      end
    end

    def sparql
      raw_sparql % subject_item_id
    end
  end
end
