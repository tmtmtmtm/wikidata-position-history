# frozen_string_literal: true

module WikidataPositionHistory
  class Report
    # A position that is usually held by a single person at a time
    # (e.g. Executive positions; president, governor, mayor, etc.)
    # The key element here is that we need to compare each officeholder
    # with others, to check for overlaps, etc.
    class Office < AbstractMandate
      def config
        {
          mandates_query_class: SPARQL::MandatesQuery,
          biodata_query_class:  SPARQL::BioQuery,
          template_class:       ReportTemplate::Office,
          mandate_class:        MandateRow,
        }
      end

      def table_rows
        padded_mandates.each_cons(3).map do |later, current, earlier|
          {
            mandate: OutputRow::Mandate.new(later, current, earlier),
            bio:     biodata_for(current.officeholder),
          }
        end
      end

      def padded_mandates
        [nil, mandates, nil].flatten(1)
      end
    end
  end
end
