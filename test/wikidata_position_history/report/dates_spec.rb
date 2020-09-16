# frozen_string_literal: true

require 'test_helper'

describe WikidataPositionHistory::Report do
  before { use_sample_data }

  let(:rows) { WikidataPositionHistory::Report.new(position_id).wikitext.split('|-') }
  let(:holder_row) { rows.find { |line| line.include? "#{officeholder}}}</span>" } }
  let(:dates) { holder_row.match(/(?<start>[\ds\-]+)\s–\s(?<end>[\ds-]+)?/).named_captures }

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
