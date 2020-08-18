# frozen_string_literal: true

require 'json'
require 'rest-client'

module QueryService
  # A SPARQL query against the Wikidata Query Service
  class Query
    WIKIDATA_SPARQL_URL = 'https://query.wikidata.org/sparql'

    def initialize(query)
      @query = query
    end

    def results
      json
    rescue RestClient::Exception => e
      raise "Wikidata query #{query} failed: #{e.message}"
    end

    private

    attr_reader :query

    def result
      @result ||= RestClient.get WIKIDATA_SPARQL_URL, accept: 'application/sparql-results+json', params: { query: query }
    end

    def json
      JSON.parse(result, symbolize_names: true)[:results][:bindings]
    end
  end
end
