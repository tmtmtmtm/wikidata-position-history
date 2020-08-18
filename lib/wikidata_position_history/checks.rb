# frozen_string_literal: true

module WikidataPositionHistory
  # Checks if an Officeholder has any warning signs to report on
  class Check
    def initialize(later, current, earlier)
      @later = later
      @current = current
      @earlier = earlier
    end

    def missing_fields
      missing = expected.reject { |field| current.send(field) }
      return unless missing.any?

      ["Missing field#{missing.count > 1 ? 's' : ''}",
       "#{current.item} is missing #{missing.map { |field| "{{P|#{field_map[field]}}}" }.join(', ')}"]
    end

    def wrong_predecessor
      return unless earlier

      replaces = current.prev or return
      prev_in_list = earlier.item or return
      return unless replaces != prev_in_list

      ['Inconsistent predecessor',
       "#{current.item} has a {{P|1365}} of #{replaces}, which differs from #{prev_in_list}"]
    end

    def wrong_successor
      return unless later

      replaced_by = current.next or return
      next_in_list = later.item or return
      return unless replaced_by != next_in_list

      ['Inconsistent sucessor',
       "#{current.item} has a {{P|1366}} of #{replaced_by}, which differs from #{next_in_list}"]
    end

    def ends_after_successor_starts
      return unless later

      ends = current.end_date or return
      next_starts = later.start_date or return
      return unless ends > next_starts

      ['Date overlap',
       "#{current.item} has a {{P|582}} of #{ends}, which is later than {{P|580}} of #{next_starts} for #{later.item}"]
    rescue ArgumentError
      ['Date precision',
       "#{current.item} has a {{P|582}} of #{ends}, which may overlap with the {{P|580}} of #{next_starts} for #{later.item}"]
    end

    private

    attr_reader :later, :current, :earlier

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
end
