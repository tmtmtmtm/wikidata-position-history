# frozen_string_literal: true

module WikidataPositionHistory
  # simplified version of a WikidataPositionHistory::Check
  Warning = Struct.new(:headline, :explanation)

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

      def party
        current.party
      end

      def officeholder
        current.officeholder
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
      def initialize(metadata)
        @metadata = metadata
      end

      def date
        return if dates.empty?

        dates.join(' / ')
      end

      private

      attr_reader :metadata

      def position_id
        metadata.position.id
      end
    end

    # Data for the Inception date of the position
    class Inception < PositionDate
      def warnings
        count = dates.count
        return [] if count == 1
        return [Warning.new('Missing field', "{{PositionHolderHistory/warning_no_inception_date|item=#{position_id}}}")] if count.zero?

        [Warning.new('Multiple values', "{{PositionHolderHistory/warning_multiple_inception_dates|item=#{position_id}}}")]
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

        [Warning.new('Multiple values', "{{PositionHolderHistory/warning_multiple_abolition_dates|item=#{position_id}}}")]
      end

      private

      def dates
        metadata.abolition_dates
      end
    end

    # Data for related position: e.g. Successor/Predecessor
    class RelatedPosition
      def initialize(metadata)
        @metadata = metadata
      end

      def position
        return if implied_list.empty?

        (implied_list.direct.map(&:qblink) + implied_list.indirect_only.map(&:qblink_i)).join(', ')
      end

      def warnings
        implied_list.indirect_only.map do |from|
          Warning.new('Indirect only', "{{PositionHolderHistory/#{indirect_warning_template}|from=#{from.id}|to=#{metadata.position.id}}}")
        end
      end

      private

      attr_reader :metadata

      def indirect_warning_template
        format('warning_indirect_%s', self.class.name.split('::').last.downcase)
      end
    end

    # Data for the position that comes after this one
    class Successor < RelatedPosition
      def implied_list
        metadata.replaced_by_combined
      end
    end

    # Data for the position that came before this one
    class Predecessor < RelatedPosition
      def implied_list
        metadata.replaces_combined
      end
    end
  end
end
