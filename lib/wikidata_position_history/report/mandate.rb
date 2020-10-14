# frozen_string_literal: true

module WikidataPositionHistory
  class Report
    # base report where each row is one person holding an office for a period
    class Mandate < Abstract
      def wikitext
        return no_items_output if mandates.empty?

        template_class.new(template_params).output
      end

      def template_params
        {
          metadata:   metadata,
          table_rows: table_rows,
          sparql_url: sparql.wdqs_url,
        }
      end

      protected

      def mandates_query_class
        config[:mandates_query_class]
      end

      def biodata_query_class
        config[:biodata_query_class]
      end

      def template_class
        config[:template_class]
      end

      def mandate_class
        config[:mandate_class]
      end

      def biodata
        @biodata ||= biodata_sparql.results_as(BioRow)
      end

      def biodata_for(officeholder)
        biodata.select { |bio| bio.person.id == officeholder.id }
      end

      def padded_mandates
        [nil, mandates, nil].flatten(1)
      end

      def sparql
        @sparql ||= mandates_query_class.new(position_id)
      end

      def biodata_sparql
        biodata_query_class.new(position_id)
      end

      def mandates
        @mandates ||= sparql.results_as(mandate_class)
      end

      def no_items_output
        "\n{{PositionHolderHistory/error_no_holders|id=#{position_id}}}\n"
      end

      def table_rows
        padded_mandates.each_cons(3).map do |later, current, earlier|
          {
            mandate: OutputRow::Mandate.new(later, current, earlier),
            bio:     biodata_for(current.officeholder),
          }
        end
      end
    end
  end
end
