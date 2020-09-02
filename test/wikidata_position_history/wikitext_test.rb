# frozen_string_literal: true

require 'test_helper'

EXPECTED_START = <<~WIKITEXT
  {| class="wikitable" style="text-align: center; border: none;"
  |-
  | style="padding:0.5em 2em" | 76.
  | style="padding:0.5em 2em" | <span style="font-size: 1.5em; display: block;">{{Q|Q264766}}</span> 2016-07-13 – 
  | style="padding:0.5em 2em 0.5em 1em; border: none; background: #fff; text-align: left;" | 
  |-
  | style="padding:0.5em 2em" | 
  | style="padding:0.5em 2em" | <span style="font-size: 1.5em; display: block;">{{Q|Q192}}</span> 2010-05-11 – 2016-07-13
  | style="padding:0.5em 2em 0.5em 1em; border: none; background: #fff; text-align: left;" | 
WIKITEXT

EXPECTED_END = <<~WIKITEXT
  |-
  | style="padding:0.5em 2em" | 
  | style="padding:0.5em 2em" | <span style="font-size: 1.5em; display: block;">{{Q|Q270415}}</span> 1742-02-16 – 1743-07-02
  | style="padding:0.5em 2em 0.5em 1em; border: none; background: #fff; text-align: left;" | 
  |-
  | style="padding:0.5em 2em" | 
  | style="padding:0.5em 2em" | <span style="font-size: 1.5em; display: block;">{{Q|Q104190}}</span> 1721-04-15 – 1742-02-27
  | style="padding:0.5em 2em 0.5em 1em; border: none; background: #fff; text-align: left;" | <span style="display: block">[[File:Pictogram voting comment.svg|15px|link=]]&nbsp;<span style="color: #d33; font-weight: bold; vertical-align: middle;">Date overlap</span>&nbsp;<ref>{{Q|Q104190}} has a {{P|582}} of 1742-02-27, which is later than the {{P|580}} of 1742-02-16 for {{Q|Q270415}}</ref></span>
  |}

  <div style="margin-bottom:5px; border-bottom:3px solid #2f74d0; font-size:8pt">
    <div style="float:right">[https://query.wikidata.org/#%23%20position-mandates%0A%0ASELECT%20DISTINCT%20%3Fordinal%20%3Fitem%20%3Fstart_date%20%3Fstart_precision%20%3Fend_date%20%3Fend_precision%20%3Fprev%20%3Fnext%20%3Fnature%0AWHERE%20%7B%0A%20%20%3Fitem%20wdt%3AP31%20wd%3AQ5%20%3B%20p%3AP39%20%3Fposn%20.%0A%20%20%3Fposn%20ps%3AP39%20wd%3AQ14211%20.%0A%20%20FILTER%20NOT%20EXISTS%20%7B%20%3Fposn%20wikibase%3Arank%20wikibase%3ADeprecatedRank%20%7D%0A%0A%20%20OPTIONAL%20%7B%20%3Fposn%20pqv%3AP580%20%5B%20wikibase%3AtimeValue%20%3Fstart_date%3B%20wikibase%3AtimePrecision%20%3Fstart_precision%20%5D%20%7D%0A%20%20OPTIONAL%20%7B%20%3Fposn%20pqv%3AP582%20%5B%20wikibase%3AtimeValue%20%3Fend_date%3B%20wikibase%3AtimePrecision%20%3Fend_precision%20%5D%20%7D%0A%20%20OPTIONAL%20%7B%20%3Fposn%20pq%3AP1365%7Cpq%3AP155%20%3Fprev%20%7D%0A%20%20OPTIONAL%20%7B%20%3Fposn%20pq%3AP1366%7Cpq%3AP156%20%3Fnext%20%7D%0A%20%20OPTIONAL%20%7B%20%3Fposn%20pq%3AP1545%20%3Fordinal%20%7D%0A%20%20OPTIONAL%20%7B%20%3Fposn%20pq%3AP5102%20%3Fnature%20%7D%0A%7D%0AORDER%20BY%20DESC%28%3Fstart_date%29%0A WDQS]</div>
  </div>
WIKITEXT

describe 'wikitext_history' do
  before { use_sample_data }

  subject { WikidataPositionHistory::Report.new('Q14211') }

  # This is just a very high level acceptance test at the moment - not
  # very useful for locating where a bug might be, but somewhat
  # helpful as a test of whether something's broken.
  it 'generates wikitext that starts how we expect' do
    expected_start = EXPECTED_START
    expect(subject.wikitext[0...expected_start.length]).must_equal expected_start
  end

  it 'generates wikitext that ends how we expect' do
    expected_end = EXPECTED_END
    expect(subject.wikitext[-expected_end.length..-1]).must_equal expected_end
  end

  it 'starts how we expect with include_header set to true' do
    expected_start = "== {{Q|Q14211}} officeholders (1721-04-04 – ) ==\n#{EXPECTED_START}"
    expect(subject.wikitext_with_header[0...expected_start.length]).must_equal expected_start
  end
end
