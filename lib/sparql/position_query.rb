# frozen_string_literal: true

module WikidataPositionHistory
  module SPARQL
    # SPARQL for fetching metadata about a position
    class PositionQuery < ItemQuery
      def raw_sparql
        <<~SPARQL
          # position-metadata

          SELECT DISTINCT ?item ?inception ?inception_precision ?abolition ?abolition_precision
                          ?replaces ?replacedBy ?derivedReplaces ?derivedReplacedBy
                          ?isPosition ?isLegislator
          WHERE {
            VALUES ?item { wd:%s }
            BIND(EXISTS { wd:%s wdt:P279+ wd:Q4164871 } as ?isPosition)
            BIND(EXISTS { wd:%s wdt:P279+ wd:Q4175034 } as ?isLegislator)
            OPTIONAL { ?item p:P571 [ a wikibase:BestRank ;
              psv:P571 [ wikibase:timeValue ?inception; wikibase:timePrecision ?inception_precision ]
            ] }
            OPTIONAL { ?item p:P576 [ a wikibase:BestRank ;
              psv:P576 [ wikibase:timeValue ?abolition; wikibase:timePrecision ?abolition_precision ]
            ] }
            OPTIONAL { ?item wdt:P1365 ?replaces }
            OPTIONAL { ?item wdt:P1366 ?replacedBy }
            OPTIONAL { ?derivedReplaces wdt:P1366 ?item }
            OPTIONAL { ?derivedReplacedBy wdt:P1365 ?item }
          }
        SPARQL
      end

      def sparql_args
        [itemid] * 3
      end
    end
  end

  # Represents a single row returned from the Position query
  class PositionRow < SPARQL::QueryRow
    def item
      item_from(:item)
    end

    def inception_date
      date_from(:inception, :inception_precision)
    end

    def abolition_date
      date_from(:abolition, :abolition_precision)
    end

    def replaces
      item_from(:replaces)
    end

    def replaced_by
      item_from(:replacedBy)
    end

    def derived_replaces
      item_from(:derivedReplaces)
    end

    def derived_replaced_by
      item_from(:derivedReplacedBy)
    end

    def position?
      raw(:isPosition) == 'true'
    end

    def legislator?
      raw(:isLegislator) == 'true'
    end
  end
end
