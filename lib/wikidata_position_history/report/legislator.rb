# frozen_string_literal: true

module WikidataPositionHistory
  class Report
    # Report for a (presumed multi-member) legislative position
    class Legislator < Abstract
      def wikitext
        "\n{{PositionHolderHistory/error_legislator|id=#{position_id}}}\n"
      end
    end
  end
end
