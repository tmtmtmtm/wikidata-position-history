# frozen_string_literal: true

require 'test_helper'

describe WikidataPositionHistory::Report do
  before { use_sample_data }

  let(:rows) { WikidataPositionHistory::Report.new(position_id).wikitext_with_header.split('|-') }
  let(:holder_row) { rows.find { |line| line.include? officeholder } }
  let(:dates) { holder_row.match(/(?<start>[\d\-]+)\s–\s(?<end>[\d-]+)?/).named_captures }

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

  describe 'High Kings of Ireland' do
    let(:position_id) { 'Q889997' }

    describe 'pre-1000 precision 11 dates' do
      let(:officeholder) { 'Q1277664' }

      it { expect(dates['start']).must_equal '879-11-24' }
      it { expect(dates['end']).must_equal '916-05-30' }
    end

    describe 'pre-1000 precision 9 dates' do
      let(:officeholder) { 'Q1283150' }

      it { expect(dates['start']).must_equal '797' }
      it { expect(dates['end']).must_equal '819' }
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