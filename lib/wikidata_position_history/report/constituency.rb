# frozen_string_literal: true

module WikidataPositionHistory
  class Report
    # Report of representatives for a single-member consttuency
    class Constituency < Mandate
      def config
        {
          mandates_query_class: SPARQL::ConstituencyMandatesQuery,
          biodata_query_class:  SPARQL::ConstituencyBioQuery,
          template_class:       ReportTemplate::Position,
          mandate_class:        MandateRow,
        }
      end

      def wikitext
        return multimember_error_template unless metadata.representative_count == 1

        super
      end

      def multimember_error_template
        "\n{{PositionHolderHistory/error_multimember}}\n"
      end
    end
  end
end
