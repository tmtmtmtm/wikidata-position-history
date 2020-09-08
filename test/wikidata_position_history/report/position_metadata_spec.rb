# frozen_string_literal: true

require 'test_helper'

describe WikidataPositionHistory::Report do
  before { use_sample_data }

  let(:report) { WikidataPositionHistory::Report.new(position_id) }
  let(:metadata) { report.template_params[:metadata] }

  describe 'office with inception but no abolition date' do
    let(:position_id) { 'Q14211' }

    it { expect(metadata.inception_date.to_s).must_equal '1721-04-04' }
    it { expect(metadata.abolition_date).must_be_nil }
  end

  describe 'office with both inception and abolition date' do
    let(:position_id) { 'Q7444267' }

    it { expect(metadata.inception_date.to_s).must_equal '1920-08-22' }
    it { expect(metadata.abolition_date.to_s).must_equal '1945' }
  end

  describe 'office with multiple inception and abolition dates' do
    let(:position_id) { 'Q3657870' }

    it { expect(metadata.inception_date.to_s).must_equal '1957 / 1969' }
    it { expect(metadata.abolition_date.to_s).must_equal '1960 / 1972' }
  end

  describe 'office with neither inception nor abolition date' do
    let(:position_id) { 'Q96424184' }

    it { expect(metadata.inception_date).must_be_nil }
    it { expect(metadata.abolition_date).must_be_nil }
    it { expect(metadata.position?).must_equal true }
  end

  describe 'legislative term' do
    let(:position_id) { 'Q20530392' }

    it { expect(metadata.position?).must_equal false }
  end
end
