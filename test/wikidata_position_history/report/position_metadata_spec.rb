# frozen_string_literal: true

require 'test_helper'

describe WikidataPositionHistory::Report do
  before { use_sample_data }

  let(:report) { WikidataPositionHistory::Report.new(position_id) }
  let(:metadata) { report.send(:metadata) }

  describe 'office with inception but no abolition date' do
    let(:position_id) { 'Q14211' }

    it { expect(metadata.inception.date.to_s).must_equal '1721-04-04' }
    it { expect(metadata.abolition.date).must_be_nil }
  end

  describe 'office with both inception and abolition date' do
    let(:position_id) { 'Q7444267' }

    it { expect(metadata.inception.date.to_s).must_equal '1920-08-22' }
    it { expect(metadata.abolition.date.to_s).must_equal '1945' }

    it { expect(metadata.abolition.warnings.first).must_be_nil }
    it { expect(metadata.inception.warnings).must_be_empty }
  end

  describe 'office with multiple inception and abolition dates' do
    let(:position_id) { 'Q3657870' }

    it { expect(metadata.inception.date.to_s).must_equal '1957 / 1969' }
    it { expect(metadata.abolition.date.to_s).must_equal '1960 / 1972' }

    it { expect(metadata.inception.warnings.first.headline).must_equal 'Multiple values' }
    it { expect(metadata.abolition.warnings.first.headline).must_equal 'Multiple values' }
  end

  describe 'office with neither inception nor abolition date' do
    let(:position_id) { 'Q96424184' }

    it { expect(metadata.inception.date).must_be_nil }
    it { expect(metadata.abolition.date).must_be_nil }
    it { expect(metadata.position?).must_equal true }

    it { expect(metadata.inception.warnings.first.headline).must_equal 'Missing field' }
    it { expect(metadata.inception.warnings.first.explanation).must_include '{{Q|Q96424184}}' }
    it { expect(metadata.abolition.warnings.first).must_be_nil }

    it { expect(metadata.predecessor.position).must_be_nil }
    it { expect(metadata.successor.position).must_be_nil }
  end

  describe 'office with replaces and replaced by' do
    let(:position_id) { 'Q38780172' }

    it { expect(metadata.predecessor.position).must_equal '{{QB|Q38780315}}' }
    it { expect(metadata.successor.position).must_equal '{{QB|Q862638}}' }
  end

  describe 'office with mutiple replaces and replaced by' do
    let(:position_id) { 'Q67202316' }

    it { expect(metadata.predecessor.position).must_equal '{{QB|Q67202278}}, {{QB|Q67202332}}' }
    it { expect(metadata.successor.position).must_equal '{{QB|Q50390723}}, {{QB|Q51280630}}' }
  end

  describe 'office with implied replaces and replaced by' do
    let(:position_id) { 'Q5068105' }

    it { expect(metadata.predecessor.position).must_be_nil }
    it { expect(metadata.predecessor.warnings).must_be_empty }
    it { expect(metadata.successor.position).must_equal "''{{QB|Q4376681}}''" }
    it { expect(metadata.successor.warnings.count).must_equal 1 }
    it { expect(metadata.successor.warnings.first.headline).must_equal 'Indirect only' }
    it { expect(metadata.successor.warnings.first.explanation).must_equal '{{PositionHolderHistory/warning_indirect_successor|from=Q4376681|to=Q5068105}}' }
  end

  describe 'legislative term' do
    let(:position_id) { 'Q20530392' }

    it { expect(metadata.position?).must_equal false }
  end
end
