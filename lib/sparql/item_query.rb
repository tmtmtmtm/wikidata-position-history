# frozen_string_literal: true

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

      private

      attr_reader :itemid

      def sparql
        raw_sparql % itemid
      end

      def json
        @json ||= QueryService::Query.new(sparql).results
      end
    end
  end
end
