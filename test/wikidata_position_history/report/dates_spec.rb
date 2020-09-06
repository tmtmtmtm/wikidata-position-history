# frozen_string_literal: true

require 'test_helper'

describe WikidataPositionHistory::Report do
  before { use_sample_data }

  let(:rows) { WikidataPositionHistory::Report.new(position_id).wikitext_with_header.split('|-') }
  let(:holder_row) { rows.find { |line| line.include? "#{officeholder}}}</span>" } }
  let(:dates) { holder_row.match(/(?<start>[\ds\-]+)\s–\s(?<end>[\ds-]+)?/).named_captures }

  describe 'Ambassador to Albania' do
    let(:position_id) { 'Q56761097' }

    describe 'precision 11 dates' do
      let(:officeholder) { 'Q507012' }

      it { expect(dates['start']).must_equal '1936-09-25' }
    end

    describe 'precision 10 dates' do
      let(:officeholder) { 'Q7326923' }

      it { expect(dates['start']).must_equal '2003-10' }
    end

    describe 'precision 9 dates' do
      let(:officeholder) { 'Q56849411' }

      it { expect(dates['start']).must_equal '2012' }
    end

    describe 'precisions in position inception dates' do
      let(:holder_row) { rows.first }

      it { expect(dates['start']).must_equal '1922' }
    end
  end

  describe 'Bishop of Worcester' do
    let(:position_id) { 'Q1837494' }

    describe 'pre-1000 dates' do
      let(:officeholder) { 'Q1273281' }

      it { expect(dates['start']).must_equal '961' }
      it { expect(dates['end']).must_equal '992-03-05' }
    end

    describe 'decade-precision dates' do
      let(:officeholder) { 'Q6860722' }

      it { expect(dates['start']).must_equal '740s' }
    end
  end

  describe 'Governor of Gibralatar' do
    let(:position_id) { 'Q195965' }

    describe 'no date line when no dates' do
      let(:officeholder) { 'Q16859171' }

      it { expect(holder_row).wont_include '–' }
    end

    describe 'no precision warnings when no dates' do
      # Robert Napier as the first 'dateless' entry is notionally followed
      # by Colin Campbell, the first 'dated' entry.
      let(:officeholder) { 'Q336474' }

      it { expect(holder_row).wont_include 'Date precision' }
    end
  end
end
