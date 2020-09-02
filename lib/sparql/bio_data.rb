# frozen_string_literal: true

module WikidataPositionHistory
  module SPARQL
    # SPARQL for fetching biographical about all holders of a position
    #
    # This is distinct from the mandate query itself to avoid complex
    # GROUP BY scenarios where people have multiple values for
    # biographical properties.
    class BioData < ItemQuery
      def raw_sparql
        <<~SPARQL
          # holder-biodata

          SELECT DISTINCT ?item ?image
          WHERE {
            ?item wdt:P31 wd:Q5 ; p:P39/ps:P39 wd:%s .
            OPTIONAL { ?item wdt:P18 ?image }
          }
          ORDER BY ?item
        SPARQL
      end
    end
  end

  # Represents a single row returned from the Position query
  class BioData
    def initialize(row)
      @row = row
    end

    def person
      QueryService::WikidataItem.new(row.dig(:item, :value))
    end

    def image_title
      return if image_url.to_s.empty?

      image_url.split('/').last
    end

    def image_link(size = 75)
      return '' unless image_title

      "[[File:#{image_title}|#{size}px]]"
    end

    private

    attr_reader :row

    def image_url
      row.dig(:image, :value)
    end
  end
end
