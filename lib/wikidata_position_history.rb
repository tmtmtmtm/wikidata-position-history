# frozen_string_literal: true

require 'query_service'
require 'sparql/item_query'
require 'sparql/position_query'
require 'sparql/bio_query'
require 'sparql/mandates_query'
require 'wikidata_position_history/checks'
require 'wikidata_position_history/template'
require 'wikidata_position_history/report'
require 'wikidata_position_history/version'

require 'date'

require 'mediawiki/client'
require 'mediawiki/page'

module WikidataPositionHistory
  # Rewrites a Wiki page
  class PageRewriter
    WIKI_TEMPLATE_NAME = 'PositionHolderHistory'
    WIKI_USERNAME = ENV['WIKI_USERNAME']
    WIKI_PASSWORD = ENV['WIKI_PASSWORD']

    NO_ID_ERROR = <<~WIKITEXT
      '''#{WIKI_TEMPLATE_NAME} Error''': You must pass the <code>id</code>
      parameter to the <code>#{WIKI_TEMPLATE_NAME}</code> template; e.g.
      <nowiki>{{#{WIKI_TEMPLATE_NAME}|id=Q14211}}</nowiki>
    WIKITEXT

    MALFORMED_ID_ERROR = <<~WIKITEXT
      '''#{WIKI_TEMPLATE_NAME} Error''': The <code>id</code> parameter was
      malformed; it should be Q followed by a number of digits, e.g. as in:

      <nowiki>{{#{WIKI_TEMPLATE_NAME}|id=Q14211}}</nowiki>
    WIKITEXT

    def initialize(mediawiki_site:, page_title:)
      @mediawiki_site = mediawiki_site
      @page_title = page_title.tr('_', ' ')
    end

    def run!
      section.replace_output(*new_content)
    end

    def new_content
      return [NO_ID_ERROR, 'The id parameter was missing'] if position_id.empty?
      return [MALFORMED_ID_ERROR, 'The id parameter was malformed'] unless position_id[/^Q\d+$/]

      [WikidataPositionHistory::Report.new(position_id).wikitext, "Successfully updated holders of #{position_id}"]
    end

    private

    attr_reader :mediawiki_site, :page_title

    def position_id
      return id_param unless id_param.empty?

      derived_id
    end

    def id_param
      section.params[:id].to_s.strip
    end

    def derived_id
      page_title.scan(/Q\d+/).last.to_s
    end

    def client
      abort 'You must set the WIKI_USERNAME and WIKI_PASSWORD environment variables' unless WIKI_USERNAME && WIKI_PASSWORD
      @client ||= MediaWiki::Client.new(
        site:     mediawiki_site,
        username: ENV['WIKI_USERNAME'],
        password: ENV['WIKI_PASSWORD']
      )
    end

    def section
      @section ||= MediaWiki::Page::ReplaceableContent.new(
        client:   client,
        title:    page_title,
        template: WIKI_TEMPLATE_NAME
      )
    end
  end
end
