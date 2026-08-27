# frozen_string_literal: true

require_relative "../../body_component"

module Emjay
  module Components
    class MjBody < BodyComponent
      def self.component_name
        "mj-body"
      end

      def self.default_attributes
        {"width" => "600px"}
      end

      def self.allowed_attributes
        {
          "width" => "unit(px)",
          "background-color" => "color",
          "id" => "string"
        }
      end

      def get_child_context
        @context.merge(container_width: get_attribute("width"))
      end

      def get_styles
        {
          body: {
            "word-spacing" => "normal",
            "background-color" => get_attribute("background-color")
          },
          div: {
            "word-spacing" => "normal",
            "background-color" => get_attribute("background-color")
          }
        }
      end

      def render
        global_data = @context[:global_data]
        lang = global_data&.lang || "und"
        dir = global_data&.dir || "auto"
        title = global_data&.title || ""
        preview = global_data&.preview || ""

        preview_html = if preview.empty?
          ""
        else
          %(\n    <div style="display:none;font-size:1px;color:#ffffff;line-height:1px;max-height:0px;max-width:0px;opacity:0;overflow:hidden;">#{preview}</div>\n  )
        end

        title_attr = title.empty? ? "" : " aria-label=\"#{title}\""

        <<~HTML
          <body#{html_attributes(id: get_attribute("id"), class: get_attribute("css-class"), style: :body)}>
            #{preview_html}
            <div#{title_attr} aria-roledescription="email" role="article" lang="#{lang}" dir="#{dir}"#{html_attributes(style: :div)}>
            #{render_children}
          </div>
          </body>
        HTML
      end
    end
  end
end
