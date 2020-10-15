# frozen_string_literal: true

module WikidataPositionHistory
  class Report
    # abstract report category, where each row is one person holding an
    # office for a period. This could either be an executive-style
    # one-person-at-a-time office (president, mayor, etc) [e.g.
    # Report::Office], or a legislative-style many-people-at-a-time one
    # [e.g. Report::Term]
    class AbstractMandate < Abstract
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
    end
  end
end
