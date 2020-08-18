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

module WikidataPositionHistory
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
      @raw_precision = precision
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
      return '11' if raw_precision.to_s.empty? # default to YYYY-MM-DD

      raw_precision.to_s
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

  # Represents a single row returned from the Position query
  class PositionData
    def initialize(row)
      @row = row
    end

    def inception_date
      WikidataDate.new(inception_date_raw, inception_date_precision)
    end

    def abolition_date
      WikidataDate.new(abolition_date_raw, abolition_date_precision)
    end

    def position?
      row.dig(:isPosition, :value) == 'true'
    end

    private

    attr_reader :row

    def inception_date_raw
      row.dig(:inception, :value).to_s[0..9]
    end

    def abolition_date_raw
      row.dig(:abolition, :value).to_s[0..9]
    end

    def inception_date_precision
      row.dig(:inception_precision, :value)
    end

    def abolition_date_precision
      row.dig(:abolition_precision, :value)
    end
  end

  # Represents a single row returned from the Mandates query
  class Mandate
    def initialize(row)
      @row = row
    end

    def ordinal
      row.dig(:ordinal, :value)
    end

    def item
      WikidataItem.new(row.dig(:item, :value)).qlink
    end

    def prev
      WikidataItem.new(row.dig(:prev, :value)).qlink
    end

    def next
      WikidataItem.new(row.dig(:next, :value)).qlink
    end

    def nature
      WikidataItem.new(row.dig(:nature, :value)).id
    end

    def acting?
      nature == 'Q4676846'
    end

    def start_date
      WikidataDate.new(start_date_raw, start_date_precision)
    end

    def end_date
      WikidataDate.new(end_date_raw, end_date_precision)
    end

    def start_date_raw
      row.dig(:start_date, :value).to_s[0..9]
    end

    def end_date_raw
      row.dig(:end_date, :value).to_s[0..9]
    end

    def start_date_precision
      row.dig(:start_precision, :value)
    end

    def end_date_precision
      row.dig(:end_precision, :value)
    end

    private

    attr_reader :row
  end

  # Checks if an Officeholder has any warning signs to report on
  class Check
    def initialize(later, current, earlier)
      @later = later
      @current = current
      @earlier = earlier
    end

    def missing_fields
      missing = expected.reject { |field| current.send(field) }
      return unless missing.any?

      ["Missing field#{missing.count > 1 ? 's' : ''}",
       "#{current.item} is missing #{missing.map { |field| "{{P|#{field_map[field]}}}" }.join(', ')}"]
    end

    def wrong_predecessor
      return unless earlier

      replaces = current.prev or return
      prev_in_list = earlier.item or return
      return unless replaces != prev_in_list

      ['Inconsistent predecessor',
       "#{current.item} has a {{P|1365}} of #{replaces}, which differs from #{prev_in_list}"]
    end

    def wrong_successor
      return unless later

      replaced_by = current.next or return
      next_in_list = later.item or return
      return unless replaced_by != next_in_list

      ['Inconsistent sucessor',
       "#{current.item} has a {{P|1366}} of #{replaced_by}, which differs from #{next_in_list}"]
    end

    def ends_after_successor_starts
      return unless later

      ends = current.end_date or return
      next_starts = later.start_date or return
      return unless ends > next_starts

      ['Date overlap',
       "#{current.item} has a {{P|582}} of #{ends}, which is later than {{P|580}} of #{next_starts} for #{later.item}"]
    rescue ArgumentError
      ['Date precision',
       "#{current.item} has a {{P|582}} of #{ends}, which may overlap with the {{P|580}} of #{next_starts} for #{later.item}"]
    end

    private

    attr_reader :later, :current, :earlier

    def field_map
      {
        start_date: 580,
        prev:       1365,
        end_date:   582,
        next:       1366,
      }
    end

    def expected
      field_map.keys.select { |field| send("expect_#{field}?") }
    end

    def expect_start_date?
      true
    end

    def expect_end_date?
      later
    end

    def expect_prev?
      return unless earlier
      return if earlier.item == current.item # sucessive terms by same person

      !current.acting?
    end

    def expect_next?
      return unless later
      return if later.item == current.item # sucessive terms by same person

      !current.acting?
    end
  end

  # A single output row of Wikitext for an officeholding
  class MandateReport
    def initialize(current, check)
      @current = current
      @check = check
    end

    def output
      [row_start, ordinal_cell, member_cell, warnings_cell].join("\n")
    end

    private

    attr_reader :current, :check

    def pictogram
      '[[File:Pictogram voting comment.svg|15px|link=]]'
    end

    def warning(check, method)
      errors = check.send(method) or return ''
      format('<span style="display: block">%s&nbsp;', pictogram) +
        format('<span style="color: #d33; font-weight: bold; vertical-align: middle;">%s</span>&nbsp;', errors.first) +
        format('<ref>%s</ref></span>', errors.last)
    end

    def row_start
      '|-'
    end

    def ordinal_cell
      %(| style="padding:0.5em 2em" | #{ordinal_string})
    end

    def ordinal_string
      ordinal = current.ordinal or return ''
      ordinal.concat('.')
    end

    def member_style
      return 'font-size: 1.25em; display: block; font-style: italic;' if current.acting?

      'font-size: 1.5em; display: block;'
    end

    def member_cell
      format('| style="padding:0.5em 2em" | <span style="%s">%s</span> %s',
             member_style, membership_person, membership_dates)
    end

    def warnings_cell
      format('| style="padding:0.5em 2em 0.5em 1em; border: none; background: #fff; text-align: left;" | %s',
             warning(check, :missing_fields) +
             warning(check, :wrong_predecessor) +
             warning(check, :wrong_successor) +
             warning(check, :ends_after_successor_starts))
    end

    def membership_person
      current.item
    end

    def membership_dates
      dates = [current.start_date, current.end_date]
      return '' if dates.compact.empty?

      dates.join(' – ')
    end
  end

  # The entire wikitext generated for this report
  class Report
    def initialize(subject_item_id)
      @subject_item_id = subject_item_id
    end

    attr_reader :subject_item_id

    def wikitext
      return no_items_output if mandates.empty?

      [table_header, table_rows, table_footer].compact.join("\n")
    end

    def header
      "== {{Q|#{subject_item_id}}} officeholders #{position_dates} =="
    end

    def position_dates
      dates = [metadata.inception_date, metadata.abolition_date]
      return '' if dates.compact.empty?

      format('(%s)', dates.join(' – '))
    end

    def wikitext_with_header
      [header, wikitext].join("\n")
    end

    private

    def metadata
      # TODO: we might get more than one response, if a position has
      # multiple dates
      @metadata ||= SPARQL::PositionData.new(subject_item_id).results_as(PositionData).first
    end

    def mandates
      @mandates ||= SPARQL::Mandates.new(subject_item_id).results_as(Mandate)
    end

    def padded_mandates
      [nil, mandates, nil].flatten(1)
    end

    def no_items_output
      "\n{{PositionHolderHistory/error_no_holders|id=#{subject_item_id}}}\n"
    end

    def table_header
      '{| class="wikitable" style="text-align: center; border: none;"'
    end

    def table_footer
      "|}\n"
    end

    def table_rows
      padded_mandates.each_cons(3).map do |later, current, earlier|
        next unless current

        check = Check.new(later, current, earlier)
        MandateReport.new(current, check).output
      end
    end
  end
end
