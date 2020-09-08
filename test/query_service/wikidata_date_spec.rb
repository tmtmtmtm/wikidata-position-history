# frozen_string_literal: true

require 'test_helper'

describe QueryService::WikidataDate do
  describe 'precision 11 dates' do
    let(:date) { QueryService::WikidataDate.new('1936-09-25', '11') }

    it { expect(date.to_s).must_equal '1936-09-25' }
  end

  describe 'precision 10 dates' do
    let(:date) { QueryService::WikidataDate.new('1936-09-01', '10') }

    it { expect(date.to_s).must_equal '1936-09' }
  end

  describe 'precision 09 dates' do
    let(:date) { QueryService::WikidataDate.new('1936-01-01', '9') }

    it { expect(date.to_s).must_equal '1936' }
  end

  describe 'precision 08 dates' do
    let(:date) { QueryService::WikidataDate.new('1930-01-01', '8') }

    it { expect(date.to_s).must_equal '1930s' }
  end

  describe 'precision 07 dates' do
    let(:date) { QueryService::WikidataDate.new('1200-01-01', '7') }

    it { expect(date.to_s).must_equal '12. century' }
  end

  describe 'pre-1000 precision 11 dates' do
    let(:date) { QueryService::WikidataDate.new('0936-09-25', '11') }

    it { expect(date.to_s).must_equal '936-09-25' }
  end

  describe 'pre-1000 precision 9 dates' do
    let(:date) { QueryService::WikidataDate.new('0936-01-01', '9') }

    it { expect(date.to_s).must_equal '936' }
  end
end
