# frozen_string_literal: true

require 'test_helper'

describe WikidataPositionHistory::Report do
  before { use_sample_data }

  let(:report) { WikidataPositionHistory::Report.new(position_id) }
  let(:metadata) { report.send(:metadata) }

  describe 'office with inception but no abolition date' do
    let(:position_id) { 'Q14211' }

    it { expect(metadata.inception.date.to_s).must_equal '1721-04-04' }
    it { expect(metadata.abolition_date).must_be_nil }
  end

  describe 'office with both inception and abolition date' do
    let(:position_id) { 'Q7444267' }

    it { expect(metadata.inception.date.to_s).must_equal '1920-08-22' }
    it { expect(metadata.abolition_date.to_s).must_equal '1945' }

    it { expect(metadata.abolition_warning).must_be_nil }
    it { expect(metadata.inception.warnings).must_be_empty }
  end

  describe 'office with multiple inception and abolition dates' do
    let(:position_id) { 'Q3657870' }

    it { expect(metadata.inception.date.to_s).must_equal '1957 / 1969' }
    it { expect(metadata.abolition_date.to_s).must_equal '1960 / 1972' }

    it { expect(metadata.inception.warnings.first.headline).must_equal 'Multiple values' }
    it { expect(metadata.abolition_warning.headline).must_equal 'Multiple values' }
  end

  describe 'office with neither inception nor abolition date' do
    let(:position_id) { 'Q96424184' }

    it { expect(metadata.inception.date).must_be_nil }
    it { expect(metadata.abolition_date).must_be_nil }
    it { expect(metadata.position?).must_equal true }

    it { expect(metadata.inception.warnings.first.headline).must_equal 'Missing field' }
    it { expect(metadata.inception.warnings.first.explanation).must_include '{{Q|Q96424184}}' }
    it { expect(metadata.abolition_warning).must_be_nil }

    it { expect(metadata.replaces).must_be_nil }
    it { expect(metadata.replaced_by).must_be_nil }
  end

  describe 'office with replaces and replaced by' do
    let(:position_id) { 'Q38780172' }

    it { expect(metadata.replaces).must_equal '{{Q|Q38780315}}' }
    it { expect(metadata.replaced_by).must_equal '{{Q|Q862638}}' }
  end

  describe 'office with mutiples replaces and replaced by' do
    let(:position_id) { 'Q67202316' }

    it { expect(metadata.replaces).must_equal '{{Q|Q67202278}}, {{Q|Q67202332}}' }
    it { expect(metadata.replaced_by).must_equal '{{Q|Q50390723}}, {{Q|Q51280630}}' }
  end

  describe 'legislative term' do
    let(:position_id) { 'Q20530392' }

    it { expect(metadata.position?).must_equal false }
  end
end
