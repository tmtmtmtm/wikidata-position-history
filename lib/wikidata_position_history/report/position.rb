# frozen_string_literal: true

module WikidataPositionHistory
  class Report
    # The default single-person-at-a-time position
    class Position < Mandate
      def mandates_query
        SPARQL::MandatesQuery
      end

      def biodata_query
        SPARQL::BioQuery
      end
    end
  end
end
