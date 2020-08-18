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

  # Represents a single row returned from the Position query
  class PositionData
    def initialize(row)
      @row = row
    end

    def inception_date
      QueryService::WikidataDate.new(inception_date_raw, inception_date_precision)
    end

    def abolition_date
      QueryService::WikidataDate.new(abolition_date_raw, abolition_date_precision)
    end

    def position?
      row.dig(:isPosition, :value) == 'true'
    end

    private

    attr_reader :row

    def inception_date_raw
      row.dig(:inception, :value).to_s[0..9]
    end

    def abolition_date_raw
      row.dig(:abolition, :value).to_s[0..9]
    end

    def inception_date_precision
      row.dig(:inception_precision, :value)
    end

    def abolition_date_precision
      row.dig(:abolition_precision, :value)
    end
  end
end
