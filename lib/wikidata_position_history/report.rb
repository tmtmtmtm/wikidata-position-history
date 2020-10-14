# frozen_string_literal: true

require_relative 'report/abstract'
require_relative 'report/legislator'
require_relative 'report/mandate'
require_relative 'report/constituency'
require_relative 'report/position'

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

    def type
      # this should be the same everywhere
      rows.map(&:type).first
    end

    def representative_count
      rows.map(&:representative_count).max
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
    def initialize(position_id)
      @position_id = position_id
      @template_class = template_class
    end

    attr_reader :position_id, :template_class

    def metadata
      @metadata ||= Metadata.new(SPARQL::PositionQuery.new(position_id).results_as(PositionRow))
    end

    def report
      report_class = {
        'legislator'   => Report::Legislator,
        'constituency' => Report::Constituency,
      }
      report_class.default = Report::Position
      report_class[metadata.type].new(metadata)
    end

    def template_params
      report.template_params
    end

    def wikitext
      report.wikitext
    end
  end
end
