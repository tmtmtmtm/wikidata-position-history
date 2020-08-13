# frozen_string_literal: true

require 'test_helper'

describe 'WikidataPositionHistory' do
  describe 'PageRewriter' do
    subject do
      stub_request(:post, 'https://www.wikidata.org/w/api.php')
        .with(body: hash_including({ 'action' => 'login' }))
        .to_return(status: 200, body: '{"login": { "result": "Success" }}')

      WikidataPositionHistory::PageRewriter.new(
        mediawiki_site: 'www.wikidata.org',
        page_title:     'User:Mhl20/Prime_minister_test'
      )
    end

    it 'should have a mediawiki_site attribute' do
      expect(subject.send(:mediawiki_site)).must_equal 'www.wikidata.org'
    end

    it 'should have a page_title attribute, where underscores have been changed to spaces' do
      expect(subject.send(:page_title)).must_equal 'User:Mhl20/Prime minister test'
    end

    it 'should error with no itemid' do
      stub_request(:get, /wikidata.org.*Prime%20minister%20test/)
        .to_return(body: '{{PositionHolderHistory}}')

      expect(subject.send(:new_content).last).must_equal 'The id parameter was missing'
    end

    it 'should error with invalid itemid' do
      stub_request(:get, /wikidata.org.*Prime%20minister%20test/)
        .to_return(body: '{{PositionHolderHistory|id=Prime Minister}}')

      expect(subject.new_content.last).must_equal 'The id parameter was malformed'
    end

    it 'should get a well-formed position ID' do
      stub_request(:get, /wikidata.org.*Prime%20minister%20test/)
        .to_return(body: '{{PositionHolderHistory|id=Q1769526}}')

      expect(subject.send(:position_id)).must_equal 'Q1769526'
    end
  end
end
