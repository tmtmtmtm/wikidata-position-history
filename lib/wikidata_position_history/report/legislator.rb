# frozen_string_literal: true

module WikidataPositionHistory
  class Report
    # Report for a (presumed multi-member) legislative position
    # (This is not handled, so is only an error template)
    class Legislator < Abstract
      def wikitext
        "\n{{PositionHolderHistory/error_legislator|id=#{position_id}}}\n"
      end
    end
  end
end
