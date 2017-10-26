require "wikidata_position_history/version"
require "wikidata_position_history/history"

module WikidataPositionHistory
  class PageRewriter
    def initialize(mediawiki_site:, page_title:)
      @mediawiki_site = mediawiki_site
      @page_title = page_title.gsub('_', ' ')
    end

    private
    attr_reader :mediawiki_site, :page_title
  end
end
