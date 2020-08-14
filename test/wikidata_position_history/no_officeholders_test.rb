# frozen_string_literal: true

require 'test_helper'

describe 'no officeholders' do
  before { use_sample_data }

  it 'outputs the no-holders template when no results' do
    result = WikidataPositionHistory::Output.new('Q39055044').wikitext
    expect(result[/{{(.*?)}}/, 1]).must_include 'error_no_holders'
  end
end
