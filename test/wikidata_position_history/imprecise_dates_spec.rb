# frozen_string_literal: true

require 'test_helper'

describe WikidataPositionHistory::Report do
  before { use_sample_data }
  let(:rows) { WikidataPositionHistory::Report.new(position_id).wikitext_with_header.split('|-') }
  let(:date_re) { /(?<start>[\d\-]+)\s–\s(?<end>[\d-]+)?/ }

  describe 'Ambassador to Albania' do
    let(:position_id) { 'Q56761097' }

    it 'handles precision 11 dates' do
      holder = rows.find { |line| line.include? 'Q507012' }
      dates = holder.match(date_re).named_captures
      expect(dates['start']).must_equal '1936-09-25'
    end

    it 'handles precision 10 dates' do
      holder = rows.find { |line| line.include? 'Q7326923' }
      dates = holder.match(date_re).named_captures
      expect(dates['start']).must_equal '2003-10'
    end

    it 'handles precision 9 dates' do
      holder = rows.find { |line| line.include? 'Q56849411' }
      dates = holder.match(date_re).named_captures
      expect(dates['start']).must_equal '2012'
    end

    it 'handles precisions in inception dates' do
      dates = rows.first.match(date_re).named_captures
      expect(dates['start']).must_equal '1922'
    end
  end

  describe 'Governor of Gibralatar' do
    let(:position_id) { 'Q195965' }

    it 'does not display date line when there are no dates' do
      holder = rows.find { |line| line.include? 'Q16859171' }
      expect(holder).wont_include '–'
    end

    it 'does not display date precision warnings when there are no dates' do
      # Robert Napier as the first 'dateless' entry is notionally followed
      # by Colin Campbell, the first 'dated' entry.
      holder = rows.find { |line| line.include? 'Q336474' }
      expect(holder).wont_include 'Date precision'
    end
  end
end
