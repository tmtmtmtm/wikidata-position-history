# frozen_string_literal: true

module WikidataPositionHistory
  # Interface to the ERB Template for the output
  class ReportTemplate
    def initialize(data)
      @data = data
    end

    def output
      template.result_with_hash(data)
    end

    private

    attr_reader :data

    def template
      @template ||= ERB.new(template_text, nil, '-')
    end

    def template_text
      <<~ERB
        {| class="wikitable" style="text-align: center; border: none;"
        <% if metadata.abolition_date -%>
        |-
        | colspan="3" style="padding:0.5em 2em; border: none; background: #fff; font-size: 1.25em; text-align: right;" | '''Position abolished''': <%= metadata.abolition_date %>
        | style="padding:0.5em 2em 0.5em 1em; border: none; background: #fff; text-align: left;" | 
        <% end -%>
        <% table_rows.map(&:values).each do |mandate, bio| -%>
        |-
        | style="padding:0.5em 2em" | <%= mandate.ordinal_string %>
        | style="padding:0.5em 2em" | <%= bio.map(&:image_link).first %>
        | style="padding:0.5em 2em" | <span style="font-size: <%= mandate.acting? ? '1.25em; font-style: italic;' : '1.5em' %>; display: block;"><%= mandate.person %></span> <%= mandate.dates %>
        | style="padding:0.5em 2em 0.5em 1em; border: none; background: #fff; text-align: left;" | \
        <% mandate.warnings.each do |warning| -%>
        <span style="display: block">[[File:Pictogram voting comment.svg|15px|link=]]&nbsp;<span style="color: #d33; font-weight: bold; vertical-align: middle;"><%= warning.headline %></span>&nbsp;<ref><%= warning.explanation %></ref></span>\
        <% end %>
        <% end -%>
        <% if metadata.inception_date -%>
        |-
        | colspan="3" style="padding:0.5em 2em; border: none; background: #fff; font-size: 1.25em; text-align: right;" | '''Position created''': <%= metadata.inception_date %>
        | style="padding:0.5em 2em 0.5em 1em; border: none; background: #fff; text-align: left;" | 
        <% end -%>
        |}

        <div style="margin-bottom:5px; border-bottom:3px solid #2f74d0; font-size:8pt">
          <div style="float:right">[<%= sparql_url %> WDQS]</div>
        </div>
        {{reflist}}
      ERB
    end
  end
end
