# frozen_string_literal: true

require 'test_helper'

describe WikidataPositionHistory::Report do
  before { use_sample_data }

  it 'outputs the no-holders template when no results' do
    result = WikidataPositionHistory::Report.new('Q39055044').wikitext
    expect(result[/{{(.*?)}}/, 1]).must_include 'error_no_holders'
  end

  describe 'warning template when the position is legislative' do
    let(:result) { WikidataPositionHistory::Report.new('Q13653224').wikitext }

    it { expect(result[/{{(.*?)}}/, 1]).must_include 'error_legislator' }
    it { expect(result[/id=(Q\d+)/, 1]).must_include 'Q13653224' }
  end

  describe 'warning template for a multi-member constituency' do
    let(:report) { WikidataPositionHistory::Report.new('Q56649104') }

    it { expect(report.send(:metadata).representative_count).must_equal 12 }
    it { expect(report.wikitext[/{{(.*?)}}/, 1]).must_include 'error_multimember' }
  end

  describe 'warning template for term with no members' do
    let(:report) { WikidataPositionHistory::Report.new('Q30744183') }

    it { expect(report.wikitext[/{{(.*?)}}/, 1]).must_include 'error_no_term_members|id=Q30744183' }
  end
end
