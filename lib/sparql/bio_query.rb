# frozen_string_literal: true

module WikidataPositionHistory
  module SPARQL
    # SPARQL for fetching biographical about all holders of a position
    #
    # This is distinct from the mandate query itself to avoid complex
    # GROUP BY scenarios where people have multiple values for
    # biographical properties.
    class BioQuery < ItemQuery
      def raw_sparql
        <<~SPARQL
          # holder-biodata

          SELECT DISTINCT ?item ?image
          WHERE {
            ?item wdt:P31 wd:Q5 ; p:P39/ps:P39 wd:__ITEMID__ .
            OPTIONAL { ?item wdt:P18 ?image }
          }
          ORDER BY ?item
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

  # Represents a single row returned from the Position query
  class BioRow < SPARQL::QueryRow
    def person
      item_from(:item)
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

    def image_url
      raw(:image)
    end
  end
end
