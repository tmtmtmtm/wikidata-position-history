# frozen_string_literal: true

module WikidataPositionHistory
  class Report
    # Report of representatives during a legislative term
    class Term < AbstractMandate
      def config
        {
          template_class:       ReportTemplate::Term,
          mandates_query_class: SPARQL::TermMandatesQuery,
          mandate_class:        TermMandateRow,
          biodata_query_class:  SPARQL::TermBioQuery,
        }
      end

      def table_rows
        mandates.map do |mandate|
          {
            mandate: OutputRow::TermMandate.new(mandate),
            bio:     biodata_for(mandate.officeholder),
          }
        end
      end
    end
  end

  module SPARQL
    # SPARQL for fetching all mandates during a legislative term
    class TermMandatesQuery < ItemQuery
      def raw_sparql
        <<~SPARQL
          # term-mandates

          SELECT DISTINCT ?item ?start_date ?start_precision ?end_date ?end_precision ?prev ?next ?party ?district ?endCause
          WHERE {
            ?item wdt:P31 wd:Q5 ; p:P39 ?posn .
            ?posn ps:P39 ?position .
            ?posn pq:P2937 wd:__ITEMID__ .
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

    # Biographical data for Members during a Term
    class TermBioQuery < ItemQuery
      def raw_sparql
        <<~SPARQL
          # term-biodata

          SELECT DISTINCT ?item ?image
          WHERE {
            ?item wdt:P31 wd:Q5 ; p:P39/pq:P2937 wd:__ITEMID__ .
            OPTIONAL { ?item wdt:P18 ?image }
          }
          ORDER BY ?item
        SPARQL
      end
    end
  end

  # Represents a single row returned from the TermMandates query
  class TermMandateRow < OfficeMandateRow
    def district
      QueryService::WikidataItem.new(row.dig(:district, :value))
    end

    def end_cause
      QueryService::WikidataItem.new(row.dig(:endCause, :value))
    end
  end
end
