# frozen_string_literal: true

module WikidataPositionHistory
  class Report
    # Report of representatives during a legislative term
    class Term < Mandate
      def mandates_query
        SPARQL::TermMandatesQuery
      end

      def template_class
        ReportTemplate::Term
      end

      def mandate_class
        TermMandateRow
      end

      def biodata_query
        SPARQL::TermBioQuery
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
