# frozen_string_literal: true

module WikidataPositionHistory
  class Report
    # Report of representatives during a legislative term
    class Term < Mandate
      def mandates_query
        SPARQL::TermMandatesQuery
      end

      def mandate_class
        TermMandateRow
      end

      def biodata_query
        SPARQL::TermBioQuery
      end
    end
  end
end
