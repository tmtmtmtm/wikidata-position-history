# frozen_string_literal: true

require 'test_helper'

describe WikidataPositionHistory::ImpliedList do
  describe 'direct only' do
    let(:list) { WikidataPositionHistory::ImpliedList.new(['Q1'], []) }

    it { expect(list.all).must_equal ['Q1'] }
    it { expect(list.direct_only).must_equal ['Q1'] }
    it { expect(list.indirect_only).must_equal [] }
    it { expect(list.both).must_equal [] }
    it { expect(list.empty?).must_equal false }
  end

  describe 'indirect only' do
    let(:list) { WikidataPositionHistory::ImpliedList.new([], ['Q1']) }

    it { expect(list.all).must_equal ['Q1'] }
    it { expect(list.direct_only).must_equal [] }
    it { expect(list.indirect_only).must_equal ['Q1'] }
    it { expect(list.both).must_equal [] }
  end

  describe 'bidirectional' do
    let(:list) { WikidataPositionHistory::ImpliedList.new(['Q1'], ['Q1']) }

    it { expect(list.all).must_equal ['Q1'] }
    it { expect(list.direct_only).must_equal [] }
    it { expect(list.indirect_only).must_equal [] }
    it { expect(list.both).must_equal ['Q1'] }
  end

  describe 'mismatch' do
    let(:list) { WikidataPositionHistory::ImpliedList.new(['Q1'], ['Q2']) }

    it { expect(list.all).must_equal %w[Q1 Q2] }
    it { expect(list.direct_only).must_equal ['Q1'] }
    it { expect(list.indirect_only).must_equal ['Q2'] }
    it { expect(list.both).must_equal [] }
  end

  describe 'partial agreement' do
    let(:list) { WikidataPositionHistory::ImpliedList.new(%w[Q1 Q2], ['Q2']) }

    it { expect(list.all).must_equal %w[Q1 Q2] }
    it { expect(list.direct_only).must_equal ['Q1'] }
    it { expect(list.indirect_only).must_equal [] }
    it { expect(list.both).must_equal ['Q2'] }
  end

  describe 'overlap' do
    let(:list) { WikidataPositionHistory::ImpliedList.new(%w[Q1 Q2], %w[Q2 Q3]) }

    it { expect(list.all).must_equal %w[Q1 Q2 Q3] }
    it { expect(list.direct_only).must_equal ['Q1'] }
    it { expect(list.indirect_only).must_equal ['Q3'] }
    it { expect(list.both).must_equal ['Q2'] }
  end

  describe 'none' do
    let(:list) { WikidataPositionHistory::ImpliedList.new([], []) }

    it { expect(list.all).must_equal [] }
    it { expect(list.direct_only).must_equal [] }
    it { expect(list.indirect_only).must_equal [] }
    it { expect(list.both).must_equal [] }
    it { expect(list.empty?).must_equal true }
  end
end
