# frozen_string_literal: true

require 'test_helper'

describe 'Ambassador to Albania' do
  before { use_sample_data }

  subject { WikidataPositionHistory::Report.new('Q56761097').wikitext_with_header.split('|-') }

  DATE_RE = /(?<start>[\d\-]+)\s–\s(?<end>[\d-]+)?/.freeze

  it 'handles precision 11 dates' do
    holder = subject.find { |line| line.include? 'Q507012' }
    dates = holder.match(DATE_RE).named_captures
    expect(dates['start']).must_equal '1936-09-25'
  end

  it 'handles precision 10 dates' do
    holder = subject.find { |line| line.include? 'Q7326923' }
    dates = holder.match(DATE_RE).named_captures
    expect(dates['start']).must_equal '2003-10'
  end

  it 'handles precision 9 dates' do
    holder = subject.find { |line| line.include? 'Q56849411' }
    dates = holder.match(DATE_RE).named_captures
    expect(dates['start']).must_equal '2012'
  end

  it 'handles precisions in inception dates' do
    dates = subject.first.match(DATE_RE).named_captures
    expect(dates['start']).must_equal '1922'
  end
end
