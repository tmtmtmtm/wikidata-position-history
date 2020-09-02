# frozen_string_literal: true

module WikidataPositionHistory
  # A single output row of Wikitext for an officeholding
  class MandateData
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
      # compact doesn't work here, even if we add #nil? to WikidataDate
      return '' if dates.reject(&:empty?).empty?

      dates.join(' – ')
    end

    def style
      return 'font-size: 1.25em; display: block; font-style: italic;' if current.acting?

      'font-size: 1.5em; display: block;'
    end

    def warnings
      CHECKS.map do |check_class|
        check = check_class.new(later, current, earlier)
        format(WARNING_LAYOUT, check.headline, check.explanation) if check.problem?
      end.join
    end

    private

    CHECKS = [Check::MissingFields, Check::WrongPredecessor, Check::WrongSuccessor, Check::Overlap].freeze

    WARNING_LAYOUT = [
      '<span style="display: block">[[File:Pictogram voting comment.svg|15px|link=]]&nbsp;',
      '<span style="color: #d33; font-weight: bold; vertical-align: middle;">%s</span>&nbsp;',
      '<ref>%s</ref></span>'
    ].join

    attr_reader :later, :current, :earlier
  end

  # The entire wikitext generated for this report
  class Report
    def initialize(subject_item_id, template_file = 'report.erb')
      @subject_item_id = subject_item_id
      @template_file = template_file
    end

    attr_reader :subject_item_id, :template_file

    def wikitext
      return no_items_output if mandates.empty?

      output
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

    def sparql
      @sparql ||= SPARQL::Mandates.new(subject_item_id)
    end

    def mandates
      @mandates ||= sparql.results_as(Mandate)
    end

    def no_items_output
      "\n{{PositionHolderHistory/error_no_holders|id=#{subject_item_id}}}\n"
    end

    def template_path
      Pathname.new(template_file)
    end

    def template
      @template ||= ERB.new(template_path.read)
    end

    def output
      template.result_with_hash(template_params)
    end

    def template_params
      {
        item:       subject_item_id,
        table_rows: table_rows,
        sparql_url: sparql.wdqs_url,
      }
    end

    def table_rows
      padded_mandates.each_cons(3).map do |later, current, earlier|
        MandateData.new(later, current, earlier)
      end
    end
  end
end
