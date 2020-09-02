# frozen_string_literal: true

require 'test_helper'

# This is just a very high level acceptance test at the moment - not
# very useful for locating where a bug might be, but somewhat
# helpful as a test of whether something's broken.

describe 'wikitext_history' do
  before { use_sample_data }
  subject { WikidataPositionHistory::Report.new('Q14211') }

  let(:expected) { Pathname.new('test/Q14211.out').read }

  it 'generates wikitext that starts how we expect' do
    expect(subject.wikitext_with_header).must_equal expected
  end
end
