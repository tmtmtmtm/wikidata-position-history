# frozen_string_literal: true

module WikidataPositionHistory
  module SPARQL
    # SPARQL for fetching all officeholdings of a position
    class MandatesQuery < ItemQuery
      def raw_sparql
        <<~SPARQL
          # position-mandates

          SELECT DISTINCT ?statement ?ordinal ?item ?start_date ?start_precision ?end_date ?end_precision ?prev ?next ?nature
          WHERE {
            ?item wdt:P31 wd:Q5 ; p:P39 ?statement .
            ?statement ps:P39 wd:%s .
            FILTER NOT EXISTS { ?statement wikibase:rank wikibase:DeprecatedRank }

            OPTIONAL { ?statement pqv:P580 [ wikibase:timeValue ?start_date; wikibase:timePrecision ?start_precision ] }
            OPTIONAL { ?statement pqv:P582 [ wikibase:timeValue ?end_date; wikibase:timePrecision ?end_precision ] }
            OPTIONAL { ?statement pq:P1365|pq:P155 ?prev }
            OPTIONAL { ?statement pq:P1366|pq:P156 ?next }
            OPTIONAL { ?statement pq:P1545 ?ordinal }
            OPTIONAL { ?statement pq:P5102 ?nature }
          }
          ORDER BY DESC(?start_date) ?item
        SPARQL
      end
    end

    # SPARQL for fetching all mandates of a single-member district
    class ConstituencyMandatesQuery < ItemQuery
      def raw_sparql
        <<~SPARQL
          # constituency-mandates

          SELECT DISTINCT ?statement ?ordinal ?item ?start_date ?start_precision ?end_date ?end_precision ?party ?prev ?next ?term
          WHERE {
            ?item wdt:P31 wd:Q5 ; p:P39 ?statement .
            ?statement pq:P768 wd:%s .
            FILTER NOT EXISTS { ?statement wikibase:rank wikibase:DeprecatedRank }

            OPTIONAL { ?statement pqv:P580 [ wikibase:timeValue ?start_date; wikibase:timePrecision ?start_precision ] }
            OPTIONAL { ?statement pqv:P582 [ wikibase:timeValue ?end_date; wikibase:timePrecision ?end_precision ] }
            OPTIONAL { ?statement pq:P1365 ?prev }
            OPTIONAL { ?statement pq:P1366 ?next }
            OPTIONAL { ?statement pq:P4100 ?party }
            OPTIONAL {
              ?statement pq:P2937 ?term .
              OPTIONAL { ?term p:P31/pq:P1545 ?ordinal }
            }
          }
          ORDER BY DESC(?start_date) ?item
        SPARQL
      end
    end
  end

  # Represents a single row returned from the Mandates query
  class MandateRow < SPARQL::QueryRow
    def statement
      raw(:statement)
    end

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
