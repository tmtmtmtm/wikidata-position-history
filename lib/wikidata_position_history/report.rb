# frozen_string_literal: true

require 'json'
require 'rest-client'

module QueryService
  # A SPARQL query against the Wikidata Query Service
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
end

module WikidataPositionHistory
  # different views of a Wikidata item
  class WikidataItem
    def initialize(url)
      @url = url
    end

    def id
      url.split('/').last unless url.to_s.empty?
    end

    def qlink
      "{{Q|#{id}}}" if id
    end

    private

    attr_reader :url
  end

  # Represents a single row returned from running the Query
  class Mandate
    def initialize(row)
      @row = row
    end

    def ordinal
      row.dig(:ordinal, :value)
    end

    def item
      WikidataItem.new(row.dig(:item, :value)).qlink
    end

    def prev
      WikidataItem.new(row.dig(:prev, :value)).qlink
    end

    def next
      WikidataItem.new(row.dig(:next, :value)).qlink
    end

    def nature
      WikidataItem.new(row.dig(:nature, :value)).id
    end

    def acting?
      nature == 'Q4676846'
    end

    def start_date
      row.dig(:start_date, :value).to_s[0..9]
    end

    def end_date
      row.dig(:end_date, :value).to_s[0..9]
    end

    private

    attr_reader :row
  end

  # Checks if an Officeholder has any warning signs to report on
  class Check
    def initialize(later, current, earlier)
      @later = later
      @current = current
      @earlier = earlier
    end

    def missing_fields
      missing = expected.reject { |field| current.send(field) }
      return unless missing.any?

      ["Missing field#{missing.count > 1 ? 's' : ''}",
       "#{current.item} is missing #{missing.map { |field| "{{P|#{field_map[field]}}}" }.join(', ')}"]
    end

    def wrong_predecessor
      return unless earlier

      replaces = current.prev or return
      prev_in_list = earlier.item or return
      return unless replaces != prev_in_list

      ['Inconsistent predecessor',
       "#{current.item} has a {{P|1365}} of #{replaces}, which differs from #{prev_in_list}"]
    end

    def wrong_successor
      return unless later

      replaced_by = current.next or return
      next_in_list = later.item or return
      return unless replaced_by != next_in_list

      ['Inconsistent sucessor',
       "#{current.item} has a {{P|1366}} of #{replaced_by}, which differs from #{next_in_list}"]
    end

    def ends_after_successor_starts
      return unless later

      ends = current.end_date or return
      next_starts = later.start_date or return
      return unless ends > next_starts

      ['Date overlap',
       "#{current.item} has a {{P|582}} of #{ends}, which is later than {{P|580}} of #{next_starts} for #{later.item}"]
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

  # A single output row of Wikitext for an officeholding
  class MandateReport
    def initialize(current, check)
      @current = current
      @check = check
    end

    def output
      [row_start, ordinal_cell, member_cell, warnings_cell].join("\n")
    end

    private

    attr_reader :current, :check

    def pictogram
      '[[File:Pictogram voting comment.svg|15px|link=]]'
    end

    def warning(check, method)
      errors = check.send(method) or return ''
      format('<span style="display: block">%s&nbsp;', pictogram) +
        format('<span style="color: #d33; font-weight: bold; vertical-align: middle;">%s</span>&nbsp;', errors.first) +
        format('<ref>%s</ref></span>', errors.last)
    end

    def row_start
      '|-'
    end

    def ordinal_cell
      %(| style="padding:0.5em 2em" | #{ordinal_string})
    end

    def ordinal_string
      ordinal = current.ordinal or return ''
      ordinal.concat('.')
    end

    def member_style
      return 'font-size: 1.25em; display: block; font-style: italic;' if current.acting?

      'font-size: 1.5em; display: block;'
    end

    def member_cell
      format('| style="padding:0.5em 2em" | <span style="%s">%s</span> %s',
             member_style, membership_person, membership_dates)
    end

    def warnings_cell
      format('| style="padding:0.5em 2em 0.5em 1em; border: none; background: #fff; text-align: left;" | %s',
             warning(check, :missing_fields) +
             warning(check, :wrong_predecessor) +
             warning(check, :wrong_successor) +
             warning(check, :ends_after_successor_starts))
    end

    def membership_person
      current.item
    end

    def membership_dates
      dates = [current.start_date, current.end_date]
      return '' if dates.compact.empty?

      dates.join(' – ')
    end
  end

  module SPARQL
    class ItemQuery
      def initialize(itemid)
        @itemid = itemid
      end

      def results_as(klass)
        json.map { |result| klass.new(result) }
      end

      private

      attr_reader :itemid

      def sparql
        raw_sparql % itemid
      end

      def json
        @json ||= QueryService::Query.new(sparql).results
      end
    end

    class Mandates < ItemQuery
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
    end
  end

  # The entire wikitext generated for this report
  class Report
    def initialize(subject_item_id)
      @subject_item_id = subject_item_id
    end

    attr_reader :subject_item_id

    def wikitext
      return no_items_output if results.empty?

      [table_header, table_rows, table_footer].compact.join("\n")
    end

    def header
      "== {{Q|#{subject_item_id}}} officeholders =="
    end

    def wikitext_with_header
      [header, wikitext].join("\n")
    end

    private

    def results
      @results ||= SPARQL::Mandates.new(subject_item_id).results_as(Mandate)
    end

    def padded_results
      [nil, results, nil].flatten(1)
    end

    def no_items_output
      "\n{{PositionHolderHistory/error_no_holders|id=#{subject_item_id}}}\n"
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
        MandateReport.new(current, check).output
      end
    end
  end
end
