# frozen_string_literal: true

module WikidataPositionHistory
  class Report
    # Report of representatives during a legislative term
    class Term < AbstractMandate
      def config
        {
          mandates_query_class: SPARQL::TermMandatesQuery,
          biodata_query_class:  SPARQL::TermBioQuery,
          template_class:       ReportTemplate::Term,
          mandate_class:        TermMandateRow,
        }
      end

      def table_rows
        mandates.map do |mandate|
          {
            mandate: OutputRow::TermMandate.new(mandate),
            bio:     biodata_for(mandate.officeholder),
          }
        end
      end
    end
  end
end
