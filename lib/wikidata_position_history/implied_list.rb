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
end
