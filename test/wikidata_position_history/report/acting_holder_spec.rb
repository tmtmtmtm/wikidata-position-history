# frozen_string_literal: true

require 'test_helper'

describe WikidataPositionHistory::Report do
  before { use_sample_data }

  let(:lines) { WikidataPositionHistory::Report.new('Q756265').wikitext.split('|-') }
  let(:jagvaral) { lines.find { |line| line.include? 'Q7070859' } }
  let(:ochirbat) { lines.find { |line| line.include? 'Q887753' } }

  it 'shows acting officeholders in italics' do
    expect(jagvaral).must_include 'italic'
  end

  it 'does not report missing successor information for acting officeholders' do
    expect(jagvaral).wont_include '1365'
    expect(jagvaral).wont_include '1366'
  end

  it 'shows regular officeholders plainly' do
    expect(ochirbat).wont_include 'italic'
  end
end
