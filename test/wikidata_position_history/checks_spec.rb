# frozen_string_literal: true

require 'test_helper'

describe 'Checks' do
  before { use_sample_data }

  let(:mandates) { WikidataPositionHistory::Report.new(position).send(:padded_mandates) }

  describe 'UK Prime Minister' do
    let(:position) { 'Q14211' }

    it 'allows for no successor for the incumbent' do
      check = WikidataPositionHistory::Check::WrongSuccessor.new(*mandates.take(3))
      expect(check.problem?).must_equal false
    end

    it 'allows for no predecessor for the earliest' do
      check = WikidataPositionHistory::Check::WrongPredecessor.new(*mandates.last(3))
      expect(check.problem?).must_equal false
    end

    it 'warns of date overlap with successor' do
      check = WikidataPositionHistory::Check::Overlap.new(*mandates.last(3))
      expect(check.problem?).must_equal true
      expect(check.headline).must_equal 'Date overlap'
    end

    it 'warns of inconsistent predecessor' do
      peel = mandates.index { |result| result&.item == '{{Q|Q181875}}' }
      check = WikidataPositionHistory::Check::WrongPredecessor.new(*mandates.slice(peel..peel + 2))
      expect(check.problem?).must_equal true
      expect(check.headline).must_equal 'Inconsistent predecessor'
    end

    it 'warns of inconsistent successor' do
      peel = mandates.index { |result| result&.item == '{{Q|Q181875}}' }
      check = WikidataPositionHistory::Check::WrongSuccessor.new(*mandates.slice(peel..peel + 2))
      expect(check.problem?).must_equal true
      expect(check.headline).must_equal 'Inconsistent successor'
    end
  end

  describe 'Prime Minister of Moldova' do
    let(:position) { 'Q1769526' }

    it 'warns of missing replaced_by' do
      check = WikidataPositionHistory::Check::MissingFields.new(*mandates.last(3))
      expect(check.explanation.scan(/{{P\|(\d+)}}/).flatten).must_equal %w[1366]
    end

    it 'does not warn of missing succession if followed by self' do
      iurie = mandates.index { |result| result&.ordinal == '10' }
      check = WikidataPositionHistory::Check::MissingFields.new(*mandates.slice(iurie - 1..iurie + 1))
      expect(check.problem?).must_equal false
      expect(check.explanation.to_s).must_equal ''
    end
  end

  describe 'Albanian Ambassador' do
    let(:position) { 'Q56761097' }

    it 'warns of imprecise dates that may overlap' do
      landsman = mandates.index { |result| result&.ordinal == '9' }
      check = WikidataPositionHistory::Check::Overlap.new(*mandates.slice(landsman - 1..landsman + 1))
      expect(check.problem?).must_equal true
      expect(check.headline).must_equal('Date precision')
    end
  end

  # Three officeholders, with no qualifiers at all
  describe 'Tanzanian Water Minister' do
    let(:position) { 'Q16147179' }

    it 'warns of missing start and end dates' do
      check = WikidataPositionHistory::Check::MissingFields.new(*mandates.drop(1).take(3))
      expect(check.explanation.scan(/{{P\|(\d+)}}/).flatten.sort).must_equal %w[1365 1366 580 582]
    end
  end
end
