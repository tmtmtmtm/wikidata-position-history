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
      # compact doesn't work here, even if we add #nil? to WikidataDate
      return '' if dates.reject(&:empty?).empty?

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

    private

    def metadata
      # TODO: we might get more than one response, if a position has
      # multiple dates
      @metadata ||= SPARQL::PositionData.new(position_id).results_as(PositionData).first
    end

    def biodata
      @biodata ||= SPARQL::BioData.new(position_id).results_as(BioData)
    end

    def biodata_for(officeholder)
      biodata.select { |bio| bio.person.id == officeholder.id }
    end

    def padded_mandates
      [nil, mandates, nil].flatten(1)
    end

    def sparql
      @sparql ||= SPARQL::Mandates.new(position_id)
    end

    def mandates
      @mandates ||= sparql.results_as(Mandate)
    end

    def no_items_output
      "\n{{PositionHolderHistory/error_no_holders|id=#{position_id}}}\n"
    end

    def output
      template_class.new(template_params).output
    end

    def template_params
      {
        table_rows: table_rows,
        sparql_url: sparql.wdqs_url,
      }
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
