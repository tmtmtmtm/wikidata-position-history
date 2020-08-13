# frozen_string_literal: true

require 'test_helper'

RESPONSES = Pathname.new('test/example-data')

describe 'wikitext_history' do
  before do
    # Stub the request that gets the results of the SPARQL query:
    stub_request(:get, %r{query.wikidata.org/sparql}).to_return do |request|
      filename = request.uri.to_s[/ps:P39%20wd:(Q\d+)/, 1] + '.json'
      { body: (RESPONSES + filename).read }
    end
  end

  # This is just a very high level acceptance test at the moment - not
  # very useful for locating where a bug might be, but somewhat
  # helpful as a test of whether something's broken.
  it 'returns expected results for the UK Prime Minister' do
    # Now try generating the history of the position holders as wikitext:
    result = WikidataPositionHistory::Output.new('Q14211').wikitext
    # Check that at least the start and end of that generated text is
    # the same:
    expected_start = '{| class="wikitable" style="text-align: center; border: none;"
|-
| style="padding:0.5em 2em" | 76.
| style="padding:0.5em 2em" | <span style="font-size: 1.5em; display: block;">{{Q|Q264766}}</span> 2016-07-13 – 
| style="padding:0.5em 2em 0.5em 1em; border: none; background: #fff; text-align: left;" | 
|-
| style="padding:0.5em 2em" | 
| style="padding:0.5em 2em" | <span style="font-size: 1.5em; display: block;">{{Q|Q192}}</span> 2010-05-11 – 2016-07-13
| style="padding:0.5em 2em 0.5em 1em; border: none; background: #fff; text-align: left;" | 
'
    expected_end = '|-
| style="padding:0.5em 2em" | 
| style="padding:0.5em 2em" | <span style="font-size: 1.5em; display: block;">{{Q|Q270415}}</span> 1742-02-16 – 1743-07-02
| style="padding:0.5em 2em 0.5em 1em; border: none; background: #fff; text-align: left;" | 
|-
| style="padding:0.5em 2em" | 
| style="padding:0.5em 2em" | <span style="font-size: 1.5em; display: block;">{{Q|Q104190}}</span> 1721-04-15 – 1742-02-27
| style="padding:0.5em 2em 0.5em 1em; border: none; background: #fff; text-align: left;" | <span style="display: block">[[File:Pictogram voting comment.svg|15px|link=]]&nbsp;<span style="color: #d33; font-weight: bold; vertical-align: middle;">Date overlap</span>&nbsp;<ref>{{Q|Q104190}} has a {{P|582}} of 1742-02-27, which is later than {{P|580}} of 1742-02-16 for {{Q|Q270415}}</ref></span>
|}
'
    expect(result[0...expected_start.length]).must_equal expected_start
    expect(result[-expected_end.length..-1]).must_equal expected_end
  end

  it 'returns expected results with include_header set to true' do
    result = WikidataPositionHistory::Output.new('Q14211').wikitext_with_header
    # Check that at least the start and end of that generated text is
    # the same:
    expected_start = '== {{Q|Q14211}} officeholders ==
{| class="wikitable" style="text-align: center; border: none;"
|-
| style="padding:0.5em 2em" | 76.
| style="padding:0.5em 2em" | <span style="font-size: 1.5em; display: block;">{{Q|Q264766}}</span> 2016-07-13 – 
| style="padding:0.5em 2em 0.5em 1em; border: none; background: #fff; text-align: left;" | 
|-
| style="padding:0.5em 2em" | 
| style="padding:0.5em 2em" | <span style="font-size: 1.5em; display: block;">{{Q|Q192}}</span> 2010-05-11 – 2016-07-13
| style="padding:0.5em 2em 0.5em 1em; border: none; background: #fff; text-align: left;" | 
'
    expect(result[0...expected_start.length]).must_equal expected_start
  end
end
