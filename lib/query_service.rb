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

  # different views of a Wikidata item
  class WikidataItem
    def initialize(url)
      @url = url
    end

    def id
      url.split('/').last unless url.to_s.empty?
    end

    def qlink
      "{{Q|#{id}}}" if id
    end

    private

    attr_reader :url
  end

  # a Wikidata date of a given precision
  class WikidataDate
    include Comparable

    def initialize(str, precision)
      @str = str
      @raw_precision = precision.to_s
    end

    def <=>(other)
      return to_s <=> other.to_s if precision == other.precision
      return year <=> other.year if year != other.year
      return month <=> other.month if month && other.month
    end

    def to_s
      return str if precision == '11'
      return str[0..6] if precision == '10'
      return str[0..3] if precision == '9'

      warn "Cannot handle precision #{precision} for #{str}"
      str
    end

    def empty?
      str.to_s.empty?
    end

    def precision
      return '11' if raw_precision.empty? # default to YYYY-MM-DD

      raw_precision
    end

    def year
      parts[0]
    end

    def month
      parts[1]
    end

    private

    attr_reader :str, :raw_precision

    def parts
      to_s.split('-')
    end
  end
end
