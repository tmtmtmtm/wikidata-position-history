# frozen_string_literal: true

# Meta-information about the 'origin' item: i.e the one passed to the
# template on-wiki.
#
# We can look up some data about this without yet knowing what 'type' of
# item we're dealing with (though not all properties will apply to all
# types), and then, based on this, decide what other classes, templates,
# queries etc to use.

module WikidataPositionHistory
  module SPARQL
    # SPARQL for fetching metadata about the origin item
    class OriginQuery < ItemQuery
      def raw_sparql
        <<~SPARQL
          # position-metadata

          SELECT DISTINCT ?item ?inception ?inception_precision ?abolition ?abolition_precision
                          ?replaces ?replacedBy ?derivedReplaces ?derivedReplacedBy
                          ?isPosition ?isLegislator ?isTerm
                          ?isConstituency ?representative_count ?legislature
          WHERE {
            VALUES ?item { wd:__ITEMID__ }
            BIND(EXISTS { wd:__ITEMID__ wdt:P279+ wd:Q4164871 } as ?isPosition)
            BIND(EXISTS { wd:__ITEMID__ wdt:P279+ wd:Q4175034 } as ?isLegislator)
            BIND(EXISTS { wd:__ITEMID__ wdt:P31/wdt:P279* wd:Q15238777 } as ?isTerm)
            BIND(EXISTS { wd:__ITEMID__ wdt:P31/wdt:P279* wd:Q192611 } as ?isConstituency)

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

            OPTIONAL { # if constituency
              ?item p:P1410 [ a wikibase:BestRank ; ps:P1410 ?representative_count ; pq:P194 ?legislature ]
            }
          }
        SPARQL
      end
    end
  end

  # Encapsulate a single row returned from the Origin query
  #  (due to combinatorial explosion when multiple values are set for
  #  any property, there could potentially be a large number of rows)
  class OriginRow < SPARQL::QueryRow
    item_field :item
    item_field :replaces
    item_field :replaced_by
    item_field :derived_replaces
    item_field :derived_replaced_by
    item_field :legislature

    def inception_date
      date_from(:inception, :inception_precision)
    end

    def abolition_date
      date_from(:abolition, :abolition_precision)
    end

    def type
      return 'constituency' if raw(:isConstituency) == 'true'
      return 'legislator'   if raw(:isLegislator) == 'true'
      return 'term'         if raw(:isTerm) == 'true'
      return 'position'     if raw(:isPosition) == 'true'
    end

    def representative_count
      raw(:representative_count).to_i
    end
  end

  # Metadata about the item specified in the template
  class OriginItem
    def initialize(rows)
      @rows = rows
    end

    def position
      rows.map(&:item).first
    end

    # TODO: this class should not know about Output logic
    # These should be the ImpliedLists, rather than OutputRows
    def predecessor
      @predecessor ||= OutputRow::Predecessor.new(self)
    end

    def successor
      @successor ||= OutputRow::Successor.new(self)
    end

    def inception
      @inception ||= OutputRow::Inception.new(self)
    end

    def abolition
      @abolition ||= OutputRow::Abolition.new(self)
    end

    def type
      # this should be the same everywhere
      rows.map(&:type).first
    end

    def representative_count
      rows.map(&:representative_count).max
    end

    def replaces_combined
      @replaces_combined ||= ImpliedList.new(uniq_by_id(:replaces), uniq_by_id(:derived_replaces))
    end

    def replaced_by_combined
      @replaced_by_combined ||= ImpliedList.new(uniq_by_id(:replaced_by), uniq_by_id(:derived_replaced_by))
    end

    def inception_dates
      rows.map(&:inception_date).compact.uniq(&:to_s).sort
    end

    def abolition_dates
      rows.map(&:abolition_date).compact.uniq(&:to_s).sort
    end

    private

    attr_reader :rows

    def uniq_by_id(method)
      rows.map(&method).compact.uniq(&:id).sort_by(&:id)
    end
  end
end
