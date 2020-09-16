# frozen_string_literal: true

module WikidataPositionHistory
  # A list made up of both direct and indirect claims, where we
  # can tell which came from which, when required
  class ImpliedList
    def initialize(direct, indirect)
      @direct = direct
      @indirect = indirect
    end

    def empty?
      all.empty?
    end

    def all
      direct | indirect
    end

    def both
      direct & indirect
    end

    def direct_only
      direct - indirect
    end

    def indirect_only
      indirect - direct
    end

    attr_reader :direct, :indirect
  end

  # Data about the position itself, to be passed to the report template
  class Metadata
    def initialize(rows)
      @rows = rows
    end

    def position
      rows.map(&:item).first
    end

    def predecessor
      @predecessor ||= OutputRow::Predecessor.new(self)
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

    def constituency?
      # this should be the same everywhere
      rows.map(&:constituency?).first
    end

    def replaces_combined
      @replaces_combined ||= ImpliedList.new(uniq_by_id(:replaces), uniq_by_id(:derived_replaces))
    end

    def replaced_by_combined
      @replaced_by_combined ||= ImpliedList.new(uniq_by_id(:replaced_by), uniq_by_id(:derived_replaced_by))
    end

    def inception_dates
      rows.map(&:inception_date).compact.uniq(&:to_s).sort
    end

    def abolition_dates
      rows.map(&:abolition_date).compact.uniq(&:to_s).sort
    end

    private

    attr_reader :rows

    def uniq_by_id(method)
      rows.map(&method).compact.uniq(&:id).sort_by(&:id)
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
      return legislator_template if metadata.legislator?
      return no_items_output if mandates.empty?

      template_class.new(template_params).output
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

    def mandates_query
      return SPARQL::ConstituencyMandatesQuery if metadata.constituency?

      SPARQL::MandatesQuery
    end

    def sparql
      @sparql ||= mandates_query.new(position_id)
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
