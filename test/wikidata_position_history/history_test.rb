require 'test_helper'

EXAMPLE_QUERY_FILENAME = File.join(File.dirname(__FILE__), '..', 'example-data', 'prime-ministers.json')

describe 'wikitext_history' do
  # This is just a very high level acceptance test at the moment - not
  # very useful for locating where a bug might be, but somewhat
  # helpful as a test of whether something's broken.
  it 'returns expected results for the UK Prime Minister' do
    # Stub the request that gets the results of the SPARQL query:
    stub_request(:get, "https://query.wikidata.org/sparql?query=%20%20SELECT%20DISTINCT%20?ordinal%20?item%20?start_date%20?end_date%20?prev%20?next%20WHERE%20%7B%0A%20%20%20%20?item%20wdt:P31%20wd:Q5%20%3B%20p:P39%20?posn%20.%0A%20%20%20%20?posn%20ps:P39%20wd:Q14211%20.%0A%20%20%20%20OPTIONAL%20%7B%20?posn%20pq:P580%20?start_date.%20%7D%0A%20%20%20%20OPTIONAL%20%7B%20?posn%20pq:P582%20?end_date.%20%7D%0A%20%20%20%20OPTIONAL%20%7B%20?posn%20pq:P1365%7Cpq:P155%20?prev.%20%7D%0A%20%20%20%20OPTIONAL%20%7B%20?posn%20pq:P1366%7Cpq:P156%20?next.%20%7D%0A%20%20%20%20OPTIONAL%20%7B%20?posn%20pq:P2715%20?election.%20%7D%0A%20%20%20%20OPTIONAL%20%7B%20?posn%20pq:P1545%20?ordinal.%20%7D%0A%20%20%7D%0A%20%20ORDER%20BY%20DESC(?start_date)%0A").
      with(headers: {'Accept'=>'application/sparql-results+json', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'query.wikidata.org', 'User-Agent'=>'rest-client/2.0.2 (linux-gnu x86_64) ruby/2.3.1p112'}).
      to_return(status: 200, body: File.read(EXAMPLE_QUERY_FILENAME), headers: {})
    # Now try generating the history of the position holders as wikitext:
    result = wikitext_history('Q14211')
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
    result[0...expected_start.length].must_equal expected_start
    result[-expected_end.length..-1].must_equal expected_end
  end
end
