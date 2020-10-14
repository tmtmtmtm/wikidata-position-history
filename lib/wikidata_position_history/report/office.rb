# frozen_string_literal: true

module WikidataPositionHistory
  class Report
    # A position that is usually held by a single person at a time
    # (e.g. Executive positions; president, governor, mayor, etc.)
    class Office < Mandate
      def config
        {
          mandates_query_class: SPARQL::MandatesQuery,
          biodata_query_class:  SPARQL::BioQuery,
          template_class:       ReportTemplate::Office,
          mandate_class:        MandateRow,
        }
      end
    end
  end
end
