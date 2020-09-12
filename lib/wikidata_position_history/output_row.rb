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

    # Base class for the Inception/Abolition date rows
    class PositionDate
      # simplified version of a WikidataPositionHistory::Check
      Warning = Struct.new(:headline, :explanation)

      def initialize(metadata)
        @metadata = metadata
      end

      def date
        return if dates.empty?

        dates.join(' / ')
      end

      private

      attr_reader :metadata

      def qlink
        metadata.item_qlink
      end
    end

    # Data for the Inception date of the position
    class Inception < PositionDate
      def warnings
        count = dates.count
        return [] if count == 1

        return [Warning.new('Missing field', "#{qlink} is missing {{P|571}}")] if count.zero?

        [Warning.new('Multiple values', "#{qlink} has more than one {{P|571}}")]
      end

      private

      def dates
        metadata.inception_dates
      end
    end

    # Data for the Abolition date of the position
    class Abolition < PositionDate
      def warnings
        return [] unless dates.count > 1

        [Warning.new('Multiple values', "#{qlink} has more than one {{P|576}}")]
      end

      private

      def dates
        metadata.abolition_dates
      end
    end

    # Data for the the position that comes after this one
    class Successor
      def initialize(metadata)
        @metadata = metadata
      end

      def position
        return if position_list.empty?

        position_list.map(&:qlink).join(', ')
      end

      # TODO: add some checks
      def warnings
        []
      end

      private

      attr_reader :metadata

      def position_list
        metadata.replaced_by_list
      end
    end
  end
end
