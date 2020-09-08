# frozen_string_literal: true

module WikidataPositionHistory
  module SPARQL
    # SPARQL for fetching all officeholdings of a position
    class MandatesQuery < ItemQuery
      def raw_sparql
        <<~SPARQL
          # position-mandates

          SELECT DISTINCT ?ordinal ?item ?start_date ?start_precision ?end_date ?end_precision ?prev ?next ?nature
          WHERE {
            ?item wdt:P31 wd:Q5 ; p:P39 ?posn .
            ?posn ps:P39 wd:%s .
            FILTER NOT EXISTS { ?posn wikibase:rank wikibase:DeprecatedRank }

            OPTIONAL { ?posn pqv:P580 [ wikibase:timeValue ?start_date; wikibase:timePrecision ?start_precision ] }
            OPTIONAL { ?posn pqv:P582 [ wikibase:timeValue ?end_date; wikibase:timePrecision ?end_precision ] }
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

  # Represents a single row returned from the Mandates query
  class MandateRow
    def initialize(row)
      @row = row
    end

    def ordinal
      row.dig(:ordinal, :value)
    end

    def officeholder
      QueryService::WikidataItem.new(row.dig(:item, :value))
    end

    # TODO: rename or remove. 'item' is meaningless/ambiguous
    def item
      officeholder.qlink
    end

    def prev
      QueryService::WikidataItem.new(row.dig(:prev, :value)).qlink
    end

    def next
      QueryService::WikidataItem.new(row.dig(:next, :value)).qlink
    end

    def nature
      QueryService::WikidataItem.new(row.dig(:nature, :value)).id
    end

    def acting?
      nature == 'Q4676846'
    end

    def start_date
      return if start_date_raw.empty?

      QueryService::WikidataDate.new(start_date_raw, start_date_precision)
    end

    def end_date
      return if end_date_raw.empty?

      QueryService::WikidataDate.new(end_date_raw, end_date_precision)
    end

    def start_date_raw
      row.dig(:start_date, :value).to_s[0..9]
    end

    def end_date_raw
      row.dig(:end_date, :value).to_s[0..9]
    end

    def start_date_precision
      row.dig(:start_precision, :value)
    end

    def end_date_precision
      row.dig(:end_precision, :value)
    end

    private

    attr_reader :row
  end
end
