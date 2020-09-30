# frozen_string_literal: true

module WikidataPositionHistory
  class Report
    # Report of representatives for a single-member consttuency
    class Constituency < Mandate
      def wikitext
        return multimember_error_template unless metadata.representative_count == 1

        super
      end

      def mandates_query
        SPARQL::ConstituencyMandatesQuery
      end

      def biodata_query
        SPARQL::ConstituencyBioQuery
      end

      def multimember_error_template
        "\n{{PositionHolderHistory/error_multimember}}\n"
      end
    end
  end
end
