# frozen_string_literal: true

module WikidataPositionHistory
  module SPARQL
    # SPARQL for fetching all officeholdings of a position
    class Mandates < ItemQuery
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
            OPTIONAL { ?posn pq:P5102 ?nature }
          }
          ORDER BY DESC(?start_date)
        SPARQL
      end
    end
  end
end
