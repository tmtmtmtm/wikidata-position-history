# frozen_string_literal: true

require 'erb'

module WikidataPositionHistory
  module SPARQL
    # Turn raw SPARQL into result objects
    class ItemQuery
      def initialize(itemid)
        @itemid = itemid
      end

      def results_as(klass)
        json.map { |result| klass.new(result) }
      end

      def wdqs_url
        "https://query.wikidata.org/##{ERB::Util.url_encode(sparql)}"
      end

      private

      attr_reader :itemid

      def sparql
        raw_sparql % sparql_args
      end

      def sparql_args
        itemid
      end

      def json
        @json ||= QueryService::Query.new(sparql).results
      end
    end
  end
end
