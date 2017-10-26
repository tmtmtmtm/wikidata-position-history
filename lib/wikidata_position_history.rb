# frozen_string_literal: true

require 'wikidata_position_history/version'
require 'wikidata_position_history/history'

require 'date'

require 'mediawiki/client'
require 'mediawiki/page'

module WikidataPositionHistory
  class RewriteError < StandardError
    def initialize(summary, wikitext)
      @wikitext = wikitext
      super(summary)
    end
    attr_reader :wikitext
  end

  class PageRewriter
    WIKI_TEMPLATE_NAME = 'PositionHolderHistory'
    WIKI_USERNAME = ENV['WIKI_USERNAME']
    WIKI_PASSWORD = ENV['WIKI_PASSWORD']

    def initialize(mediawiki_site:, page_title:)
      @mediawiki_site = mediawiki_site
      @page_title = page_title.tr('_', ' ')
    end

    def check_login_available
      return if WIKI_USERNAME && WIKI_PASSWORD
      abort 'You must set the WIKI_USERNAME and WIKI_PASSWORD environment variables'
    end

    def check_id_supplied(item_id)
      return if item_id
      raise RewriteError.new(
        'The id parameter was missing',
        "'''#{WIKI_TEMPLATE_NAME} Error''': You must pass the <code>id</code> " \
        "parameter to the <code>#{WIKI_TEMPLATE_NAME}</code> template; e.g.\n\n" \
        " <nowiki>{{#{WIKI_TEMPLATE_NAME}|id=Q14211}}</nowiki>\n"
      )
    end

    def check_id_well_formed(item_id)
      return if item_id =~ /Q\d+/
      raise RewriteError.new(
        'The id parameter was malformed',
        "'''#{WIKI_TEMPLATE_NAME} Error''': The <code>id</code> parameter was " \
        "malformed; it should be Q followed by a number of digits, e.g. as in:\n\n" \
        " <nowiki>{{#{WIKI_TEMPLATE_NAME}|id=Q14211}}</nowiki>\n"
      )
    end

    def position_id
      section.params[:id].tap do |item_id|
        check_id_supplied(item_id)
        check_id_well_formed(item_id)
      end
    end

    def client
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

    def run!
      check_login_available
      begin
        new_wikitext = wikitext_history(position_id)
        section.replace_output(new_wikitext, "Last updated at: #{DateTime.now}")
      rescue RewriteError => e
        section.replace_output(e.wikitext, e.to_s)
      end
    end

    private

    attr_reader :mediawiki_site, :page_title
  end
end
