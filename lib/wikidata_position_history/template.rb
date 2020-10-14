# frozen_string_literal: true

module WikidataPositionHistory
  # Interface to the ERB Template for the output
  class ReportTemplate
    # Base class for report templates, to be overriden for each type
    class Base
      def initialize(data)
        @data = data
      end

      def output
        template.result_with_hash(data)
      end

      private

      attr_reader :data

      def template
        @template ||= ERB.new(template_text, nil, '-')
      end
    end
  end
end

require_relative 'template/position'
require_relative 'template/term'
