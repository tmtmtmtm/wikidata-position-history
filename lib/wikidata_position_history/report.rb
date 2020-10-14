# frozen_string_literal: true

require_relative 'report/abstract'
require_relative 'report/mandate'
require_relative 'report/office'
require_relative 'report/legislator'
require_relative 'report/constituency'
require_relative 'report/term'

module WikidataPositionHistory
  # The entire wikitext generated for this report
  class Report
    def initialize(position_id)
      @position_id = position_id
      @template_class = template_class
    end

    attr_reader :position_id, :template_class

    def metadata
      @metadata ||= OriginItem.new(SPARQL::OriginQuery.new(position_id).results_as(OriginRow))
    end

    def report
      report_class = {
        'legislator'   => Report::Legislator,
        'constituency' => Report::Constituency,
        'term'         => Report::Term,
      }
      report_class.default = Report::Office
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
