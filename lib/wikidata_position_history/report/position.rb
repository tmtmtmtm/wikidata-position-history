# frozen_string_literal: true

module WikidataPositionHistory
  class Report
    # The default single-person-at-a-time position
    class Position < Mandate
      def config
        {
          mandates_query_class: SPARQL::MandatesQuery,
          biodata_query_class:  SPARQL::BioQuery,
          template_class:       ReportTemplate::Position,
          mandate_class:        MandateRow,
        }
      end
    end
  end
end
