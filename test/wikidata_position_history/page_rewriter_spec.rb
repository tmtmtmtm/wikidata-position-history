# frozen_string_literal: true

require 'test_helper'

describe 'WikidataPositionHistory' do
  before { fake_login }

  describe 'PrimeMinisterTest' do
    let(:page) do
      WikidataPositionHistory::PageRewriter.new(
        mediawiki_site: 'www.wikidata.org',
        page_title:     'User:Mhl20/Prime_minister_test'
      )
    end

    it 'has a mediawiki_site attribute' do
      expect(page.send(:mediawiki_site)).must_equal 'www.wikidata.org'
    end

    it 'has a page_title attribute, where underscores have been changed to spaces' do
      expect(page.send(:page_title)).must_equal 'User:Mhl20/Prime minister test'
    end

    it 'errors with no itemid' do
      stub_request(:get, /wikidata.org.*Prime%20minister%20test/)
        .to_return(body: '{{PositionHolderHistory}}')

      expect(page.send(:position_id)).must_be_empty
      expect(page.send(:new_content).last).must_equal 'The id parameter was missing'
    end

    it 'errors with invalid itemid' do
      stub_request(:get, /wikidata.org.*Prime%20minister%20test/)
        .to_return(body: '{{PositionHolderHistory|id=Prime Minister}}')

      expect(page.new_content.last).must_equal 'The id parameter was malformed'
    end

    it 'gets a well-formed position ID' do
      stub_request(:get, /wikidata.org.*Prime%20minister%20test/)
        .to_return(body: '{{PositionHolderHistory|id=Q1769526}}')

      expect(page.send(:position_id)).must_equal 'Q1769526'
    end
  end

  describe 'DerivedIDs' do
    it 'derives an item from the Page where none supplied' do
      stub_request(:get, /wikidata.org.*Talk:Q42/)
        .to_return(body: '{{PositionHolderHistory}}')

      expect(WikidataPositionHistory::PageRewriter.new(
        mediawiki_site: 'www.wikidata.org',
        page_title:     'Talk:Q42'
      ).send(:position_id)).must_equal 'Q42'
    end

    it 'takes the last ID from the Page name if multiple options' do
      stub_request(:get, %r{wikidata.org.*Talk:Q42/Q1769526})
        .to_return(body: '{{PositionHolderHistory}}')

      expect(WikidataPositionHistory::PageRewriter.new(
        mediawiki_site: 'www.wikidata.org',
        page_title:     'Talk:Q42/Q1769526'
      ).send(:position_id)).must_equal 'Q1769526'
    end

    it 'prefers the ID in the template, even if one is in the URL' do
      stub_request(:get, /wikidata.org.*Talk:Q42/)
        .to_return(body: '{{PositionHolderHistory|id=Q1769526}}')

      expect(WikidataPositionHistory::PageRewriter.new(
        mediawiki_site: 'www.wikidata.org',
        page_title:     'Talk:Q42'
      ).send(:position_id)).must_equal 'Q1769526'
    end
  end
end
