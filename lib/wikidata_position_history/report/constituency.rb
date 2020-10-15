# frozen_string_literal: true

module WikidataPositionHistory
  class Report
    # Report of representatives for a single-member consttuency
    class Constituency < Office
      def config
        {
          template_class:       ReportTemplate::Office,
          mandates_query_class: SPARQL::ConstituencyMandatesQuery,
          mandate_class:        OfficeMandateRow,
          biodata_query_class:  SPARQL::ConstituencyBioQuery,
        }
      end

      def wikitext
        return multimember_error_template unless metadata.representative_count == 1

        super
      end

      def multimember_error_template
        "\n{{PositionHolderHistory/error_multimember}}\n"
      end
    end
  end

  module SPARQL
    # SPARQL for fetching all mandates of a single-member district
    class ConstituencyMandatesQuery < ItemQuery
      def raw_sparql
        <<~SPARQL
          # constituency-mandates

          SELECT DISTINCT ?ordinal ?item ?start_date ?start_precision ?end_date ?end_precision ?party ?prev ?next ?term
          WHERE {
            ?item wdt:P31 wd:Q5 ; p:P39 ?posn .
            ?posn pq:P768 wd:__ITEMID__ .
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

    # Biographical data for Members for a Constituency
    class ConstituencyBioQuery < ItemQuery
      def raw_sparql
        <<~SPARQL
          # constituency-biodata

          SELECT DISTINCT ?item ?image
          WHERE {
            ?item wdt:P31 wd:Q5 ; p:P39/pq:P768 wd:__ITEMID__ .
            OPTIONAL { ?item wdt:P18 ?image }
          }
          ORDER BY ?item
        SPARQL
      end
    end
  end
end
