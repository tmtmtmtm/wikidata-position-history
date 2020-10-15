# frozen_string_literal: true

module WikidataPositionHistory
  class Report
    # A position that is usually held by a single person at a time
    # (e.g. Executive positions; president, governor, mayor, etc.)
    # The key element here is that we need to compare each officeholder
    # with others, to check for overlaps, etc.
    class Office < AbstractMandate
      def config
        {
          template_class:       ReportTemplate::Office,
          mandates_query_class: SPARQL::OfficeMandatesQuery,
          mandate_class:        OfficeMandateRow,
          biodata_query_class:  SPARQL::OfficeBioQuery,
        }
      end

      def table_rows
        padded_mandates.each_cons(3).map do |later, current, earlier|
          {
            mandate: OutputRow::Mandate.new(later, current, earlier),
            bio:     biodata_for(current.officeholder),
          }
        end
      end

      def padded_mandates
        [nil, mandates, nil].flatten(1)
      end
    end
  end

  module SPARQL
    # SPARQL for fetching all officeholdings of a position
    class OfficeMandatesQuery < ItemQuery
      def raw_sparql
        <<~SPARQL
          # position-mandates

          SELECT DISTINCT ?ordinal ?item ?start_date ?start_precision ?end_date ?end_precision ?prev ?next ?nature
          WHERE {
            ?item wdt:P31 wd:Q5 ; p:P39 ?posn .
            ?posn ps:P39 wd:__ITEMID__ .
            FILTER NOT EXISTS { ?posn wikibase:rank wikibase:DeprecatedRank }

            OPTIONAL { ?posn pqv:P580 [ wikibase:timeValue ?start_date; wikibase:timePrecision ?start_precision ] }
            OPTIONAL { ?posn pqv:P582 [ wikibase:timeValue ?end_date; wikibase:timePrecision ?end_precision ] }
            OPTIONAL { ?posn pq:P1365|pq:P155 ?prev }
            OPTIONAL { ?posn pq:P1366|pq:P156 ?next }
            OPTIONAL { ?posn pq:P1545 ?ordinal }
            OPTIONAL { ?posn pq:P5102 ?nature }
          }
          ORDER BY DESC(?start_date) ?item
        SPARQL
      end
    end

    # SPARQL for fetching biographical about all holders of a position
    #
    # This is distinct from the mandate query itself to avoid complex
    # GROUP BY scenarios where people have multiple values for
    # biographical properties.
    class OfficeBioQuery < ItemQuery
      def raw_sparql
        <<~SPARQL
          # holder-biodata

          SELECT DISTINCT ?item ?image
          WHERE {
            ?item wdt:P31 wd:Q5 ; p:P39/ps:P39 wd:__ITEMID__ .
            OPTIONAL { ?item wdt:P18 ?image }
          }
          ORDER BY ?item
        SPARQL
      end
    end
  end

  # Represents a single row returned from the OfficeMandates query
  class OfficeMandateRow < SPARQL::QueryRow
    def ordinal
      raw(:ordinal)
    end

    def officeholder
      item_from(:item)
    end

    def party
      item_from(:party)
    end

    # TODO: switch to item_from
    def prev
      QueryService::WikidataItem.new(row.dig(:prev, :value)).qlink
    end

    # TODO: switch to item_from
    def next
      QueryService::WikidataItem.new(row.dig(:next, :value)).qlink
    end

    # TODO: switch to item_from
    def nature
      QueryService::WikidataItem.new(row.dig(:nature, :value)).id
    end

    def acting?
      nature == 'Q4676846'
    end

    def start_date
      date_from(:start_date, :start_precision)
    end

    def end_date
      date_from(:end_date, :end_precision)
    end
  end
end
