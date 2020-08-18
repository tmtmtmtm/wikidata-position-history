# frozen_string_literal: true

module WikidataPositionHistory
  module SPARQL
    # SPARQL for fetching metadata about a position
    class PositionData < ItemQuery
      def raw_sparql
        <<~SPARQL
          # position-metadata

          SELECT DISTINCT ?inception ?inception_precision ?abolition ?abolition_precision ?isPosition
          WHERE {
            VALUES ?item { wd:%s }
            BIND(EXISTS { ?item wdt:P279+ wd:Q4164871  } as ?isPosition)
            OPTIONAL { ?item p:P571/psv:P571 [ wikibase:timeValue ?inception; wikibase:timePrecision ?inception_precision ] }
            OPTIONAL { ?item p:P576/psv:P576 [ wikibase:timeValue ?abolition; wikibase:timePrecision ?abolition_precision ] }
            SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
          }
        SPARQL
      end
    end
  end
end
