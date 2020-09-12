# frozen_string_literal: true

module WikidataPositionHistory
  class OutputRow
    # Date for a single mandate row, to be passed to the report template
    class Mandate
      CHECKS = [Check::MissingFields, Check::Overlap,
                Check::WrongPredecessor, Check::MissingPredecessor,
                Check::WrongSuccessor, Check::MissingSuccessor].freeze

      def initialize(later, current, earlier)
        @later = later
        @current = current
        @earlier = earlier
      end

      def ordinal_string
        ordinal = current.ordinal or return ''
        "#{ordinal}."
      end

      def person
        current.item
      end

      def dates
        dates = [current.start_date, current.end_date]
        return '' if dates.compact.empty?

        dates.join(' – ')
      end

      def acting?
        current.acting?
      end

      def warnings
        CHECKS.map { |klass| klass.new(later, current, earlier) }.select(&:problem?)
      end

      private

      attr_reader :later, :current, :earlier
    end
  end
end
