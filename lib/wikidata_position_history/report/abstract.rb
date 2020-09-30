# frozen_string_literal: true

module WikidataPositionHistory
  class Report
    # Abstract base class for Reports
    class Abstract
      def initialize(metadata)
        @metadata = metadata
      end

      protected

      attr_reader :metadata

      def position_id
        metadata.position.id
      end
    end
  end
end
