# frozen_string_literal: true

require 'test_helper'

describe 'WikidataPositionHistory' do
  describe 'PageRewriter' do
    subject do
      WikidataPositionHistory::PageRewriter.new(
        mediawiki_site: 'www.wikidata.org',
        page_title:     'User:Mhl20/Prime_minister_test'
      )
    end

    it 'should have a mediawiki_site attribute' do
      subject.send(:mediawiki_site).must_equal 'www.wikidata.org'
    end

    it 'should have a page_title attribute, where underscores have been changed to spaces' do
      subject.send(:page_title).must_equal 'User:Mhl20/Prime minister test'
    end
  end
end
