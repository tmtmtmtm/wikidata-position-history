# frozen_string_literal: true

module WikidataPositionHistory
  # A single output row of Wikitext for an officeholding
  class MandateReport
    def initialize(later, current, earlier)
      @later = later
      @current = current
      @earlier = earlier
    end

    def output
      [row_start, ordinal_cell, member_cell, warnings_cell].join("\n")
    end

    private

    CHECKS = [Check::MissingFields, Check::WrongPredecessor, Check::WrongSuccessor, Check::Overlap].freeze

    WARNING_LAYOUT = [
      '<span style="display: block">[[File:Pictogram voting comment.svg|15px|link=]]&nbsp;',
      '<span style="color: #d33; font-weight: bold; vertical-align: middle;">%s</span>&nbsp;',
      '<ref>%s</ref></span>'
    ].join

    attr_reader :later, :current, :earlier

    def row_start
      '|-'
    end

    def ordinal_cell
      %(| style="padding:0.5em 2em" | #{ordinal_string})
    end

    def ordinal_string
      ordinal = current.ordinal or return ''
      ordinal.concat('.')
    end

    def member_style
      return 'font-size: 1.25em; display: block; font-style: italic;' if current.acting?

      'font-size: 1.5em; display: block;'
    end

    def member_cell
      format('| style="padding:0.5em 2em" | <span style="%s">%s</span> %s',
             member_style, membership_person, membership_dates)
    end

    def warnings_cell
      format('| style="padding:0.5em 2em 0.5em 1em; border: none; background: #fff; text-align: left;" | %s',
             combined_warnings)
    end

    def combined_warnings
      CHECKS.map do |check_class|
        check = check_class.new(later, current, earlier)
        format(WARNING_LAYOUT, check.headline, check.explanation) if check.problem?
      end.join
    end

    def membership_person
      current.item
    end

    def membership_dates
      dates = [current.start_date, current.end_date]
      return '' if dates.compact.empty?

      dates.join(' – ')
    end
  end

  # The entire wikitext generated for this report
  class Report
    def initialize(subject_item_id)
      @subject_item_id = subject_item_id
    end

    attr_reader :subject_item_id

    def wikitext
      return no_items_output if mandates.empty?

      [table_header, table_rows, table_footer].compact.join("\n")
    end

    def header
      "== {{Q|#{subject_item_id}}} officeholders #{position_dates} =="
    end

    def position_dates
      dates = [metadata.inception_date, metadata.abolition_date]
      return '' if dates.compact.empty?

      format('(%s)', dates.join(' – '))
    end

    def wikitext_with_header
      [header, wikitext].join("\n")
    end

    private

    def metadata
      # TODO: we might get more than one response, if a position has
      # multiple dates
      @metadata ||= SPARQL::PositionData.new(subject_item_id).results_as(PositionData).first
    end

    def padded_mandates
      [nil, mandates, nil].flatten(1)
    end

    def mandates
      @mandates ||= SPARQL::Mandates.new(subject_item_id).results_as(Mandate)
    end

    def no_items_output
      "\n{{PositionHolderHistory/error_no_holders|id=#{subject_item_id}}}\n"
    end

    def table_header
      '{| class="wikitable" style="text-align: center; border: none;"'
    end

    def table_footer
      "|}\n"
    end

    def table_rows
      padded_mandates.each_cons(3).map do |later, current, earlier|
        MandateReport.new(later, current, earlier).output
      end
    end
  end
end
