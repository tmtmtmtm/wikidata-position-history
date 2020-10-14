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
          ORDER BY DESC(?start_date) ?item
        SPARQL
      end
    end

    # SPARQL for fetching all mandates of a single-member district
    class ConstituencyMandatesQuery < ItemQuery
      def raw_sparql
        <<~SPARQL
          # constituency-mandates

          SELECT DISTINCT ?ordinal ?item ?start_date ?start_precision ?end_date ?end_precision ?party ?prev ?next ?term
          WHERE {
            ?item wdt:P31 wd:Q5 ; p:P39 ?posn .
            ?posn pq:P768 wd:%s .
            FILTER NOT EXISTS { ?posn wikibase:rank wikibase:DeprecatedRank }

            OPTIONAL { ?posn pqv:P580 [ wikibase:timeValue ?start_date; wikibase:timePrecision ?start_precision ] }
            OPTIONAL { ?posn pqv:P582 [ wikibase:timeValue ?end_date; wikibase:timePrecision ?end_precision ] }
            OPTIONAL { ?posn pq:P1365 ?prev }
            OPTIONAL { ?posn pq:P1366 ?next }
            OPTIONAL { ?posn pq:P4100 ?party }
            OPTIONAL {
              ?posn pq:P2937 ?term .
              OPTIONAL { ?term p:P31/pq:P1545 ?ordinal }
            }
          }
          ORDER BY DESC(?start_date) ?item
        SPARQL
      end
    end

    # SPARQL for fetching all mandates during a legislative term
    class TermMandatesQuery < ItemQuery
      def raw_sparql
        <<~SPARQL
          # term-mandates

          SELECT DISTINCT ?item ?start_date ?start_precision ?end_date ?end_precision ?prev ?next ?party ?district ?endCause
          WHERE {
            ?item wdt:P31 wd:Q5 ; p:P39 ?posn .
            ?posn ps:P39 ?position .
            ?posn pq:P2937 wd:%s .
            FILTER NOT EXISTS { ?posn wikibase:rank wikibase:DeprecatedRank }

            OPTIONAL { ?posn pqv:P580 [ wikibase:timeValue ?start_date; wikibase:timePrecision ?start_precision ] }
            OPTIONAL { ?posn pqv:P582 [ wikibase:timeValue ?end_date; wikibase:timePrecision ?end_precision ] }
            OPTIONAL { ?posn pq:P1365|pq:P155 ?prev }
            OPTIONAL { ?posn pq:P1366|pq:P156 ?next }
            OPTIONAL { ?posn pq:P4100 ?party }
            OPTIONAL { ?posn pq:P768 ?district }
            OPTIONAL { ?posn pq:P1534 ?endCause }
          }
          ORDER BY ?start_date ?item
        SPARQL
      end
    end
  end

  # Represents a single row returned from the Mandates query
  class MandateRow < SPARQL::QueryRow
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

  # Represents a single row returned from the TermMandates query
  class TermMandateRow < MandateRow
    def district
      QueryService::WikidataItem.new(row.dig(:district, :value))
    end

    def end_cause
      QueryService::WikidataItem.new(row.dig(:endCause, :value))
    end
  end
end
