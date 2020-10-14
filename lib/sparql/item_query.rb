# frozen_string_literal: true

require 'erb'

module WikidataPositionHistory
  module SPARQL
    # Abstract class to turn raw SPARQL into result objects
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
        raw_sparql.gsub('__ITEMID__', itemid)
      end

      def json
        @json ||= QueryService::Query.new(sparql).results
      end
    end

    # Abstract class to represents a single row returned from a query
    class QueryRow
      def initialize(row)
        @row = row
      end

      protected

      attr_reader :row

      def item_from(key)
        value = raw(key)
        return if value.to_s.empty?

        QueryService::WikidataItem.new(value)
      end

      def date_from(key, precision_key)
        trunc = raw(key).to_s[0..9]
        return if trunc.empty?

        QueryService::WikidataDate.new(trunc, raw(precision_key))
      end

      def raw(key)
        row.dig(key, :value)
      end
    end
  end
end
