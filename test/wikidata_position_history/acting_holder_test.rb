# frozen_string_literal: true

require 'test_helper'

describe 'acting officeholders' do
  before { use_sample_data }

  it 'shows acting officeholders in italics' do
    output = WikidataPositionHistory::Output.new('Q756265').wikitext.split('|-')
    jagvaral = output.find { |line| line.include? 'Q7070859' }
    expect(jagvaral).must_include 'italic'
  end

  it 'does not report missing successor information for acting officeholders' do
    output = WikidataPositionHistory::Output.new('Q756265').wikitext.split('|-')
    jagvaral = output.find { |line| line.include? 'Q7070859' }
    expect(jagvaral).wont_include '1365'
    expect(jagvaral).wont_include '1366'
  end

  it 'shows regular officeholders plainly' do
    output = WikidataPositionHistory::Output.new('Q756265').wikitext.split('|-')
    ochirbat = output.find { |line| line.include? 'Q887753' }
    expect(ochirbat).wont_include 'italic'
  end
end
