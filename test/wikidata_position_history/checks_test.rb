# frozen_string_literal: true

require 'test_helper'

describe 'Checks' do
  before { use_sample_data }

  describe 'UK Prime Minister' do
    subject { WikidataPositionHistory::Report.new('Q14211').send(:padded_mandates) }

    it 'allows for no successor for the incumbent' do
      check = WikidataPositionHistory::Check.new(*subject.take(3))
      expect(check.wrong_successor).must_be_nil
    end

    it 'allows for no predecessor for the earliest' do
      check = WikidataPositionHistory::Check.new(*subject.last(3))
      expect(check.wrong_predecessor).must_be_nil
    end

    it 'warns of date overlap with successor' do
      check = WikidataPositionHistory::Check.new(*subject.last(3))
      expect(check.ends_after_successor_starts.first).must_equal 'Date overlap'
    end

    it 'warns of inconsistent succession' do
      peel = subject.index { |result| result&.item == '{{Q|Q181875}}' }
      check = WikidataPositionHistory::Check.new(*subject.slice(peel..peel + 2))
      expect(check.wrong_predecessor.first).must_equal 'Inconsistent predecessor'
      expect(check.wrong_successor.first).must_equal 'Inconsistent sucessor'
    end
  end

  describe 'Prime Minister of Moldova' do
    subject { WikidataPositionHistory::Report.new('Q1769526').send(:padded_mandates) }

    it 'warns of missing replaced_by' do
      check = WikidataPositionHistory::Check.new(*subject.last(3))
      expect(check.missing_fields.last).must_include '{{P|1366}}'
    end

    it 'does not warn of missing succession if followed by self' do
      iurie = subject.index { |result| result&.ordinal == '10' }
      check = WikidataPositionHistory::Check.new(*subject.slice(iurie - 1..iurie + 1))
      expect(check.missing_fields.to_a).must_be_empty
    end
  end

  describe 'Albanian Ambassador' do
    subject { WikidataPositionHistory::Report.new('Q56761097').send(:padded_mandates) }

    it 'warns of imprecise dates that may overlap' do
      landsman = subject.index { |result| result&.ordinal == '9' }
      check = WikidataPositionHistory::Check.new(*subject.slice(landsman - 1..landsman + 1))
      expect(check.ends_after_successor_starts.first).must_equal('Date precision')
    end
  end
end