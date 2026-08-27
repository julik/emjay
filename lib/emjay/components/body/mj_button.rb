# frozen_string_literal: true

require_relative "../../body_component"
require_relative "../../helpers/width_parser"

module Emjay
  module Components
    class MjButton < BodyComponent
      def self.component_name
        "mj-button"
      end

      def self.ending_tag?
        true
      end

      def self.default_attributes
        {
          "align" => "center",
          "background-color" => "#414141",
          "border" => "none",
          "border-radius" => "3px",
          "color" => "#ffffff",
          "font-family" => "Ubuntu, Helvetica, Arial, sans-serif",
          "font-size" => "13px",
          "font-weight" => "normal",
          "inner-padding" => "10px 25px",
          "line-height" => "120%",
          "padding" => "10px 25px",
          "target" => "_blank",
          "text-decoration" => "none",
          "text-transform" => "none",
          "vertical-align" => "middle"
        }
      end

      def self.allowed_attributes
        {
          "align" => "enum(left,center,right)",
          "background-color" => "color",
          "border-bottom" => "string",
          "border-left" => "string",
          "border-radius" => "string",
          "border-right" => "string",
          "border-top" => "string",
          "border" => "string",
          "color" => "color",
          "container-background-color" => "color",
          "font-family" => "string",
          "font-size" => "unit(px)",
          "font-style" => "string",
          "font-weight" => "string",
          "height" => "unit(px,%)",
          "href" => "string",
          "name" => "string",
          "title" => "string",
          "inner-padding" => "unit(px,%){1,4}",
          "letter-spacing" => "unitWithNegative(px,em)",
          "line-height" => "unit(px,%,)",
          "padding-bottom" => "unit(px,%)",
          "padding-left" => "unit(px,%)",
          "padding-right" => "unit(px,%)",
          "padding-top" => "unit(px,%)",
          "padding" => "unit(px,%){1,4}",
          "rel" => "string",
          "target" => "string",
          "text-decoration" => "string",
          "text-transform" => "string",
          "vertical-align" => "enum(top,bottom,middle)",
          "text-align" => "enum(left,right,center)",
          "width" => "unit(px,%)"
        }
      end

      def get_styles
        {
          table: {
            "border-collapse" => "separate",
            "width" => get_attribute("width"),
            "line-height" => "100%"
          },
          td: {
            "border" => get_attribute("border"),
            "border-bottom" => get_attribute("border-bottom"),
            "border-left" => get_attribute("border-left"),
            "border-radius" => get_attribute("border-radius"),
            "border-right" => get_attribute("border-right"),
            "border-top" => get_attribute("border-top"),
            "cursor" => "auto",
            "font-style" => get_attribute("font-style"),
            "height" => get_attribute("height"),
            "mso-padding-alt" => get_attribute("inner-padding"),
            "text-align" => get_attribute("text-align"),
            "background" => get_attribute("background-color")
          },
          content: {
            "display" => "inline-block",
            "width" => calculate_a_width(get_attribute("width")),
            "background" => get_attribute("background-color"),
            "color" => get_attribute("color"),
            "font-family" => get_attribute("font-family"),
            "font-size" => get_attribute("font-size"),
            "font-style" => get_attribute("font-style"),
            "font-weight" => get_attribute("font-weight"),
            "line-height" => get_attribute("line-height"),
            "letter-spacing" => get_attribute("letter-spacing"),
            "margin" => "0",
            "text-decoration" => get_attribute("text-decoration"),
            "text-transform" => get_attribute("text-transform"),
            "padding" => get_attribute("inner-padding"),
            "mso-padding-alt" => "0px",
            "border-radius" => get_attribute("border-radius")
          }
        }
      end

      def render
        tag = get_attribute("href") ? "a" : "p"

        bgcolor = get_attribute("background-color")
        bgcolor_attr = (bgcolor == "none") ? nil : bgcolor

        tag_attrs = if tag == "a"
          html_attributes(
            href: get_attribute("href"),
            name: get_attribute("name"),
            rel: get_attribute("rel"),
            title: get_attribute("title"),
            style: :content,
            target: get_attribute("target")
          )
        else
          html_attributes(
            href: get_attribute("href"),
            name: get_attribute("name"),
            rel: get_attribute("rel"),
            title: get_attribute("title"),
            style: :content
          )
        end

        table_attrs = html_attributes(
          border: "0",
          cellpadding: "0",
          cellspacing: "0",
          role: "presentation",
          style: :table
        )

        td_attrs = html_attributes(
          align: "center",
          bgcolor: bgcolor_attr,
          role: "presentation",
          style: :td,
          valign: get_attribute("vertical-align")
        )

        <<~HTML
          <table
            #{table_attrs}
          >
            <tbody>
              <tr>
                <td
                  #{td_attrs}
                >
                  <#{tag}
                    #{tag_attrs}
                  >
                    #{get_content}
                  </#{tag}>
                </td>
              </tr>
            </tbody>
          </table>
        HTML
      end

      private

      def calculate_a_width(width)
        return nil unless width

        parsed = WidthParser.call(width)
        return nil unless parsed[:unit] == "px"

        borders = get_box_widths[:borders]
        inner_paddings = get_shorthand_attr_value("inner-padding", "left") +
          get_shorthand_attr_value("inner-padding", "right")

        "#{parsed[:parsed_width] - inner_paddings - borders}px"
      end
    end
  end
end
