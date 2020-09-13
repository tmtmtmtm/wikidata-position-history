# frozen_string_literal: true

require 'test_helper'

# This is a very high level acceptance test to check that the full
# output for a position is as expected.
#
# More detailed tests should hopefully uncover the specifics of any
# problem: this is a fallback to catch anything slipping through.
#
# These will require more maintenance than other tests: the expectation
# is that the source data and expected output *should* be regenerated
# from time to time.

describe WikidataPositionHistory::Report do
  before { use_sample_data }

  let(:report)   { WikidataPositionHistory::Report.new(id) }
  let(:pathname) { Pathname.new("test/expected-output/#{id}.out") }
  let(:expected) do
    # uncomment this to regenerate all the reports
    # pathname.write report.wikitext_with_header
    pathname.read
  end

  describe 'Prime Minister of the United Kingdom' do
    let(:id) { 'Q14211' }

    it { expect(report.wikitext_with_header).must_equal expected }
  end

  describe 'Secretary for Mines' do
    let(:id) { 'Q7444267' }

    it { expect(report.wikitext_with_header).must_equal expected }
  end

  describe 'Ambassador to Albania' do
    let(:id) { 'Q56761097' }

    it { expect(report.wikitext_with_header).must_equal expected }
  end

  describe 'Prime Minister of Ghana' do
    let(:id) { 'Q3657870' }

    it { expect(report.wikitext_with_header).must_equal expected }
  end

  describe 'Federal Minister of Economics and Technology' do
    let(:id) { 'Q30533307' }

    it { expect(report.wikitext_with_header).must_equal expected }
  end

  describe 'Bishop of Worcester' do
    let(:id) { 'Q1837494' }

    it { expect(report.wikitext_with_header).must_equal expected }
  end
end
