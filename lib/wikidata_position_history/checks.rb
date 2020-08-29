# frozen_string_literal: true

module WikidataPositionHistory
  # Checks if an Officeholder has any warning signs to report on
  class Check
    def initialize(later, current, earlier)
      @later = later
      @current = current
      @earlier = earlier
    end

    def explanation
      possible_explanation if problem?
    end

    protected

    attr_reader :later, :current, :earlier

    def successor
      current.next
    end

    def predecessor
      current.prev
    end

    def latest_holder?
      !!later
    end

    def earliest_holder?
      !!earlier
    end
  end

  class Check
    # Does the Officeholder have all the properties we expect?
    class MissingFields < Check
      def problem?
        missing.any?
      end

      def headline
        "Missing field#{missing.count > 1 ? 's' : ''}"
      end

      def possible_explanation
        "#{current.item} is missing #{missing.map { |field| "{{P|#{field_map[field]}}}" }.join(', ')}"
      end

      def missing
        expected.reject { |field| current.send(field) }
      end

      def field_map
        {
          start_date: 580,
          prev:       1365,
          end_date:   582,
          next:       1366,
        }
      end

      def expected
        field_map.keys.select { |field| send("expect_#{field}?") }
      end

      def expect_start_date?
        true
      end

      def expect_end_date?
        later
      end

      def expect_prev?
        return unless earlier
        return if earlier.item == current.item # sucessive terms by same person

        !current.acting?
      end

      def expect_next?
        return unless later
        return if later.item == current.item # sucessive terms by same person

        !current.acting?
      end
    end

    # Does the 'replaces' match the previous item in the list?
    class WrongPredecessor < Check
      def problem?
        earliest_holder? && !!predecessor && (earlier.item != predecessor)
      end

      def headline
        'Inconsistent predecessor'
      end

      def possible_explanation
        "#{current.item} has a {{P|1365}} of #{predecessor}, which differs from #{earlier.item}"
      end
    end

    # Does the 'replaced by' match the next item in the list?
    class WrongSuccessor < Check
      def problem?
        latest_holder? && !!successor && (later.item != successor)
      end

      def headline
        'Inconsistent successor'
      end

      def possible_explanation
        "#{current.item} has a {{P|1366}} of #{successor}, which differs from #{later.item}"
      end
    end

    # Does the end date overlap with the successor's start date?
    class Overlap < Check
      def problem?
        return false unless later

        ends = current.end_date
        return false if ends.empty?

        ends > later.start_date
      rescue ArgumentError
        true
      end

      def headline
        comparable? ? 'Date overlap' : 'Date precision'
      end

      def possible_explanation
        "#{current.item} has a {{P|582}} of #{current.end_date}, which #{overlap_explanation} the {{P|580}} of #{later.start_date} for #{later.item}"
      end

      protected

      def comparable?
        # Seems like there must be a better way to do this
        [current.end_date, later.start_date].sort
      rescue ArgumentError
        false
      end

      def overlap_explanation
        comparable? ? 'is later than' : 'may overlap with'
      end
    end
  end
end
