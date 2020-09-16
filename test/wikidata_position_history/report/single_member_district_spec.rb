# frozen_string_literal: true

require 'test_helper'

describe WikidataPositionHistory::Report do
  before { use_sample_data }

  let(:lines) { WikidataPositionHistory::Report.new('Q751651').template_params[:table_rows] }
  let(:mandates) { lines.map { |line| line[:mandate] } }
  let(:donaldson_mandates) { mandates.select { |mandate| mandate.officeholder.id == 'Q300292' } }

  it 'has two distinct MPs' do
    expect(mandates.map(&:officeholder).uniq(&:id).count).must_equal 2
  end

  it 'has lots of Donaldson mandates' do
    expect(donaldson_mandates.count).must_equal 9
  end

  it 'has Donaldson in multiple different parties' do
    # DUP / Independent / UUP
    expect(donaldson_mandates.map(&:party).map(&:id).uniq.to_set).must_equal %w[Q215519 Q327591 Q841045].to_set
  end
end
