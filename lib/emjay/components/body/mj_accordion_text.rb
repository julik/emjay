# frozen_string_literal: true

require_relative "../../body_component"

module Emjay
  module Components
    class MjAccordionText < BodyComponent
      def self.component_name
        "mj-accordion-text"
      end

      def self.ending_tag?
        true
      end

      def self.default_attributes
        {
          "font-size" => "13px",
          "line-height" => "1",
          "padding" => "16px"
        }
      end

      def self.allowed_attributes
        {
          "background-color" => "color",
          "font-size" => "unit(px)",
          "font-family" => "string",
          "font-weight" => "string",
          "letter-spacing" => "unitWithNegative(px,em)",
          "line-height" => "unit(px,%,)",
          "color" => "color",
          "padding-bottom" => "unit(px,%)",
          "padding-left" => "unit(px,%)",
          "padding-right" => "unit(px,%)",
          "padding-top" => "unit(px,%)",
          "padding" => "unit(px,%){1,4}"
        }
      end

      def get_styles
        {
          td: {
            "background" => get_attribute("background-color"),
            "font-size" => get_attribute("font-size"),
            "font-family" => resolve_font_family,
            "font-weight" => get_attribute("font-weight"),
            "letter-spacing" => get_attribute("letter-spacing"),
            "line-height" => get_attribute("line-height"),
            "color" => get_attribute("color"),
            "padding" => get_attribute("padding"),
            "padding-bottom" => get_attribute("padding-bottom"),
            "padding-left" => get_attribute("padding-left"),
            "padding-right" => get_attribute("padding-right"),
            "padding-top" => get_attribute("padding-top")
          },
          table: {
            "width" => "100%",
            "border-bottom" => get_attribute("border")
          }
        }
      end

      def render
        content_attrs = html_attributes(class: "mj-accordion-content")
        table_attrs = html_attributes(
          cellspacing: "0",
          cellpadding: "0",
          style: :table
        )

        <<~HTML
          <div
            #{content_attrs}
          >
            <table
              #{table_attrs}
            >
              <tbody>
                <tr>
                  #{render_content}
                </tr>
              </tbody>
            </table>
          </div>
        HTML
      end

      private

      def resolve_font_family
        raw_attrs = @props[:raw_attrs] || {}
        if raw_attrs.key?("font-family")
          return get_attribute("font-family")
        end
        if @context[:elementFontFamily]
          return @context[:elementFontFamily]
        end
        if @context[:accordionFontFamily]
          return @context[:accordionFontFamily]
        end
        self.class.default_attributes["font-family"]
      end

      def render_content
        td_attrs = html_attributes(
          class: get_attribute("css-class"),
          style: :td
        )
        <<~HTML
          <td
            #{td_attrs}
          >
            #{get_content}
          </td>
        HTML
      end
    end
  end
end
