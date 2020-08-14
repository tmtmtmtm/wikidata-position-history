#!/usr/bin/env ruby
# frozen_string_literal: true

require 'wikidata_position_history'

id = ARGV.first or abort "Usage: #{$PROGRAM_NAME} <Qid>"

output_example = Pathname.new("test/example-data/#{id}.json")
query = WikidataPositionHistory::Output.new(id).send(:sparql)
res = WikidataPositionHistory::Query.new(query).send(:result)

output_example.write res
