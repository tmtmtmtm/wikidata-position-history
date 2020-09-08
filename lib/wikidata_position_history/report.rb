# frozen_string_literal: true

module WikidataPositionHistory
  # Date for a single mandate row, to be passed to the report template
  class MandateData
    CHECKS = [Check::MissingFields, Check::WrongPredecessor, Check::WrongSuccessor, Check::Overlap].freeze

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

  # Data about the position itself, to be passed to the report template
  class Metadata
    # simplified version of a WikidataPositionHistory::Check
    Warning = Struct.new(:headline, :explanation)

    def initialize(rows)
      @rows = rows
    end

    def item
      rows.map(&:item).first
    end

    def inception_date
      return if inception_dates.empty?

      inception_dates.join(' / ')
    end

    def inception_warning
      count = inception_dates.count

      return if count == 1
      return Warning.new('Missing field', "#{item_qlink} is missing {{P|571}}") if count.zero?

      Warning.new('Multiple values', "#{item_qlink} has more than one {{P|571}}")
    end

    def abolition_date
      return if abolition_dates.empty?

      abolition_dates.join(' / ')
    end

    def abolition_warning
      return unless abolition_dates.count > 1

      Warning.new('Multiple values', "#{item_qlink} has more than one {{P|576}}")
    end

    def position?
      # this should be the same everywhere
      rows.map(&:position?).first
    end

    private

    attr_reader :rows

    def inception_dates
      rows.map(&:inception_date).compact.uniq(&:to_s).sort
    end

    def abolition_dates
      rows.map(&:abolition_date).compact.uniq(&:to_s).sort
    end

    def item_qlink
      item.qlink
    end
  end

  # The entire wikitext generated for this report
  class Report
    def initialize(position_id, template_class = ReportTemplate)
      @position_id = position_id
      @template_class = template_class
    end

    attr_reader :position_id, :template_class

    def wikitext
      return no_items_output if mandates.empty?

      output
    end

    def header
      "== {{Q|#{position_id}}} officeholders #{position_dates} =="
    end

    def position_dates
      dates = [metadata.inception_date, metadata.abolition_date]
      return '' if dates.compact.empty?

      format('(%s)', dates.join(' – '))
    end

    def wikitext_with_header
      [header, wikitext].join("\n")
    end

    def template_params
      {
        metadata:   metadata,
        table_rows: table_rows,
        sparql_url: sparql.wdqs_url,
      }
    end

    private

    def metadata
      @metadata ||= Metadata.new(SPARQL::PositionQuery.new(position_id).results_as(PositionRow))
    end

    def biodata
      @biodata ||= SPARQL::BioQuery.new(position_id).results_as(BioRow)
    end

    def biodata_for(officeholder)
      biodata.select { |bio| bio.person.id == officeholder.id }
    end

    def padded_mandates
      [nil, mandates, nil].flatten(1)
    end

    def sparql
      @sparql ||= SPARQL::MandatesQuery.new(position_id)
    end

    def mandates
      @mandates ||= sparql.results_as(MandateRow)
    end

    def no_items_output
      "\n{{PositionHolderHistory/error_no_holders|id=#{position_id}}}\n"
    end

    def output
      template_class.new(template_params).output
    end

    def table_rows
      padded_mandates.each_cons(3).map do |later, current, earlier|
        {
          mandate: MandateData.new(later, current, earlier),
          bio:     biodata_for(current.officeholder),
        }
      end
    end
  end
end
