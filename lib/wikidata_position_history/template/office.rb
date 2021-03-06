# frozen_string_literal: true

module WikidataPositionHistory
  class ReportTemplate
    # ERB output template for Office and Constituency types
    class Office < Base
      def template_text
        <<~ERB
          {| class="wikitable" style="text-align: center; border: none;"
          <% if metadata.abolition.date -%>
          |-
          | colspan="2" style="border: none; background: #fff; font-size: 1.15em; text-align: right;" | '''Position abolished''':
          | style="border: none; background: #fff; text-align: left;" | <%= metadata.abolition.date %>
          | style="border: none; background: #fff; text-align: left;" | \
          <% metadata.abolition.warnings.each do |warning| -%>
          <span style="display: block">[[File:Pictogram voting comment.svg|15px|link=]]&nbsp;<span style="color: #d33; font-weight: bold; vertical-align: middle;"><%= warning.headline %></span>&nbsp;<ref><%= warning.explanation %></ref></span>\
          <% end %>
          <% end -%>
          <% if metadata.successor.position -%>
          |-
          | colspan="2" style="border: none; background: #fff; font-size: 1.15em; vertical-align: baseline; text-align: right;" | '''Replaced by''':
          | style=" border: none; background: #fff; vertical-align: baseline; text-align: left;" | <%= metadata.successor.position %>
          | style=" border: none; background: #fff; text-align: left;" | \
          <% metadata.successor.warnings.each do |warning| -%>
          <span style="display: block">[[File:Pictogram voting comment.svg|15px|link=]]&nbsp;<span style="color: #d33; font-weight: bold; vertical-align: middle;"><%= warning.headline %></span>&nbsp;<ref><%= warning.explanation %></ref></span>\
          <% end %>
          <% end -%>
          <% if metadata.successor.position || metadata.abolition.date -%>
          |-
          | colspan="3" style="padding:0.5em; border: none; background: #fff"> |&nbsp;
          | colspan="1" style="padding:0.5em; border: none; background: #fff"> |&nbsp;
          <% end -%>
          <% table_rows.map(&:values).each do |mandate, bio| -%>
          |-
          | style="padding:0.5em 2em" | <%= mandate.ordinal_string %>
          | style="padding:0.5em 2em" | <%= bio.map(&:image_link).first %>
          | style="padding:0.5em 2em" | <span style="font-size: <%= mandate.acting? ? '1.25em; font-style: italic;' : '1.5em' %>; display: block;"><%= mandate.officeholder.qlink %></span> <%= mandate.dates %>
          <% if metadata.type == 'constituency' -%>
          | style="padding:0.5em 1em" | <% if mandate.party %><%= mandate.party.qlink %><% end %>
          <% end -%>
          | style="padding:0.5em 2em 0.5em 1em; border: none; background: #fff; text-align: left;" | \
          <% mandate.warnings.each do |warning| -%>
          <span style="display: block">[[File:Pictogram voting comment.svg|15px|link=]]&nbsp;<span style="color: #d33; font-weight: bold; vertical-align: middle;"><%= warning.headline %></span>&nbsp;<ref><%= warning.explanation %></ref></span>\
          <% end %>
          <% end -%>
          <% if metadata.successor.position || metadata.abolition.date -%>
          |-
          | colspan="3" style="padding:0.5em; border: none; background: #fff"> |&nbsp;
          | colspan="1" style="padding:0.5em; border: none; background: #fff"> |&nbsp;
          <% end -%>
          <% if metadata.inception.date || metadata.inception.warnings.any? -%>
          |-
          | colspan="2" style="border: none; background: #fff; font-size: 1.15em; text-align: right;" | '''Position created''':
          | style="border: none; background: #fff; text-align: left;" | <%= metadata.inception.date %>
          | style="padding:0.5em 2em 0.5em 1em; border: none; background: #fff; text-align: left;" | \
          <% metadata.inception.warnings.each do |warning| -%>
          <span style="display: block">[[File:Pictogram voting comment.svg|15px|link=]]&nbsp;<span style="color: #d33; font-weight: bold; vertical-align: middle;"><%= warning.headline %></span>&nbsp;<ref><%= warning.explanation %></ref></span>\
          <% end %>
          <% end -%>
          <% if metadata.predecessor.position -%>
          |-
          | colspan="2" style=" border: none; background: #fff; font-size: 1.15em; text-align: right;" | '''Replaces''':
          | style="border: none; background: #fff; text-align: left;" | <%= metadata.predecessor.position %>
          | style="padding:0.5em 2em 0.5em 1em; border: none; background: #fff; text-align: left;" | \
          <% metadata.predecessor.warnings.each do |warning| -%>
          <span style="display: block">[[File:Pictogram voting comment.svg|15px|link=]]&nbsp;<span style="color: #d33; font-weight: bold; vertical-align: middle;"><%= warning.headline %></span>&nbsp;<ref><%= warning.explanation %></ref></span>\
          <% end %>
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
end
