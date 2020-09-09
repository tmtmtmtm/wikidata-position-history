# frozen_string_literal: true

require 'test_helper'

describe WikidataPositionHistory::Report do
  before { use_sample_data }

  it 'outputs the no-holders template when no results' do
    result = WikidataPositionHistory::Report.new('Q39055044').wikitext
    expect(result[/{{(.*?)}}/, 1]).must_include 'error_no_holders'
  end

  it 'outputs a warning template when the position is legislative' do
    result = WikidataPositionHistory::Report.new('Q13653224').wikitext
    expect(result[/{{(.*?)}}/, 1]).must_include 'error_legislator'
  end
end