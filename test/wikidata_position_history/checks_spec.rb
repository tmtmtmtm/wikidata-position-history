# frozen_string_literal: true

require 'test_helper'

describe 'Checks' do
  before { use_sample_data }

  describe 'UK Prime Minister' do
    subject { WikidataPositionHistory::Report.new('Q14211').send(:padded_mandates) }

    it 'allows for no successor for the incumbent' do
      check = WikidataPositionHistory::Check::WrongSuccessor.new(*subject.take(3))
      expect(check.problem?).must_equal false
    end

    it 'allows for no predecessor for the earliest' do
      check = WikidataPositionHistory::Check::WrongPredecessor.new(*subject.last(3))
      expect(check.problem?).must_equal false
    end

    it 'warns of date overlap with successor' do
      check = WikidataPositionHistory::Check::Overlap.new(*subject.last(3))
      expect(check.problem?).must_equal true
      expect(check.headline).must_equal 'Date overlap'
    end

    it 'warns of inconsistent succession' do
      peel = subject.index { |result| result&.item == '{{Q|Q181875}}' }
      check = WikidataPositionHistory::Check::WrongPredecessor.new(*subject.slice(peel..peel + 2))
      expect(check.problem?).must_equal true
      expect(check.headline).must_equal 'Inconsistent predecessor'
    end

    it 'warns of inconsistent succession' do
      peel = subject.index { |result| result&.item == '{{Q|Q181875}}' }
      check = WikidataPositionHistory::Check::WrongSuccessor.new(*subject.slice(peel..peel + 2))
      expect(check.problem?).must_equal true
      expect(check.headline).must_equal 'Inconsistent successor'
    end
  end

  describe 'Prime Minister of Moldova' do
    subject { WikidataPositionHistory::Report.new('Q1769526').send(:padded_mandates) }

    it 'warns of missing replaced_by' do
      check = WikidataPositionHistory::Check::MissingFields.new(*subject.last(3))
      expect(check.problem?).must_equal true
      expect(check.explanation).must_include '{{P|1366}}'
    end

    it 'does not warn of missing succession if followed by self' do
      iurie = subject.index { |result| result&.ordinal == '10' }
      check = WikidataPositionHistory::Check::MissingFields.new(*subject.slice(iurie - 1..iurie + 1))
      expect(check.problem?).must_equal false
      expect(check.explanation.to_s).must_equal ''
    end
  end

  describe 'Albanian Ambassador' do
    subject { WikidataPositionHistory::Report.new('Q56761097').send(:padded_mandates) }

    it 'warns of imprecise dates that may overlap' do
      landsman = subject.index { |result| result&.ordinal == '9' }
      check = WikidataPositionHistory::Check::Overlap.new(*subject.slice(landsman - 1..landsman + 1))
      expect(check.problem?).must_equal true
      expect(check.headline).must_equal('Date precision')
    end
  end
end
