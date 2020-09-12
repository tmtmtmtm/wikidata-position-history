# frozen_string_literal: true

module WikidataPositionHistory
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

    def replaces
      return if replaces_list.empty?

      replaces_list.map(&:qlink).join(', ')
    end

    def successor
      @successor ||= OutputRow::Successor.new(self)
    end

    def inception
      @inception ||= OutputRow::Inception.new(self)
    end

    def abolition
      @abolition ||= OutputRow::Abolition.new(self)
    end

    def position?
      # this should be the same everywhere
      rows.map(&:position?).first
    end

    def legislator?
      # this should be the same everywhere
      rows.map(&:legislator?).first
    end

    def replaces_list
      rows.map(&:replaces).compact.uniq(&:id).sort_by(&:id)
    end

    def replaced_by_list
      rows.map(&:replaced_by).compact.uniq(&:id).sort_by(&:id)
    end

    def inception_dates
      rows.map(&:inception_date).compact.uniq(&:to_s).sort
    end

    def abolition_dates
      rows.map(&:abolition_date).compact.uniq(&:to_s).sort
    end

    def item_qlink
      item.qlink
    end

    private

    attr_reader :rows
  end

  # The entire wikitext generated for this report
  class Report
    def initialize(position_id, template_class = ReportTemplate)
      @position_id = position_id
      @template_class = template_class
    end

    attr_reader :position_id, :template_class

    def wikitext
      return legislator_template if metadata.legislator?
      return no_items_output if mandates.empty?

      template_class.new(template_params).output
    end

    def header
      "== {{Q|#{position_id}}} officeholders #{position_dates} =="
    end

    def position_dates
      dates = [metadata.inception.date, metadata.abolition.date]
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

    def legislator_template
      "\n{{PositionHolderHistory/error_legislator|id=#{position_id}}}\n"
    end

    def table_rows
      padded_mandates.each_cons(3).map do |later, current, earlier|
        {
          mandate: OutputRow::Mandate.new(later, current, earlier),
          bio:     biodata_for(current.officeholder),
        }
      end
    end
  end
end
