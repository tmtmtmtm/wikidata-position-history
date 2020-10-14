# frozen_string_literal: true

module WikidataPositionHistory
  class ReportTemplate
    # ERB output template for a Term
    class Term < Base
      def template_text
        <<~ERB
          {| class="wikitable sortable" style="text-align: center; border: none;"
          !'''{{P|18}}'''
          !'''Name'''
          !'''{{P|4100}}'''
          !'''{{P|768}}'''
          |-
          <% table_rows.map(&:values).each do |mandate, bio| -%>
          |-
          | style="padding:0.5em 2em" | <%= bio.map(&:image_link).first %>
          | style="padding:0.5em 2em" | <span style="font-size: 1.5em; display: block;"><%= mandate.officeholder.qlink %></span> <%= mandate.dates %>
          | style="padding:0.5em 1em" | <% if mandate.party %><%= mandate.party.qlink %><% end %>
          | style="padding:0.5em 1em" | <% if mandate.district %><%= mandate.district.qlink %><% end %>
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
