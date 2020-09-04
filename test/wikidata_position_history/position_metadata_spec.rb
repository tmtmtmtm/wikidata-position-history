# frozen_string_literal: true

require 'test_helper'

describe 'Checks' do
  before { use_sample_data }

  describe 'office with inception but no abolition date' do
    subject { WikidataPositionHistory::Report.new('Q14211').send(:metadata) }

    it 'has an inception date' do
      expect(subject.inception_date.to_s).must_equal '1721-04-04'
    end

    it 'has no abolition date' do
      expect(subject.abolition_date).must_be_empty
    end
  end

  describe 'office with both inception and abolition date' do
    subject { WikidataPositionHistory::Report.new('Q7444267').send(:metadata) }

    it 'has an inception date' do
      expect(subject.inception_date.to_s).must_equal '1920-08-22'
    end

    it 'has an abolition date' do
      expect(subject.abolition_date.to_s).must_equal '1945'
    end
  end

  describe 'office with neither inception nor abolition date' do
    subject { WikidataPositionHistory::Report.new('Q258045').send(:metadata) }

    it 'has no inception date' do
      expect(subject.inception_date).must_be_empty
    end

    it 'has no abolition date' do
      expect(subject.abolition_date).must_be_empty
    end

    it 'knows that it is a position' do
      expect(subject.position?).must_equal true
    end
  end

  describe 'legislative term' do
    subject { WikidataPositionHistory::Report.new('Q20530392').send(:metadata) }

    it 'knows that it is not a position' do
      expect(subject.position?).must_equal false
    end
  end
end
