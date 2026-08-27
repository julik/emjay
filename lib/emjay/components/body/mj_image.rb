# frozen_string_literal: true

require_relative "../../body_component"
require_relative "../../helpers/width_parser"
require_relative "../../helpers/make_lower_breakpoint"

module Emjay
  module Components
    class MjImage < BodyComponent
      def self.component_name
        "mj-image"
      end

      def self.default_attributes
        {
          "alt" => "",
          "align" => "center",
          "border" => "0",
          "height" => "auto",
          "padding" => "10px 25px",
          "target" => "_blank",
          "font-size" => "13px"
        }
      end

      def self.allowed_attributes
        {
          "alt" => "string",
          "href" => "string",
          "name" => "string",
          "src" => "string",
          "srcset" => "string",
          "sizes" => "string",
          "title" => "string",
          "rel" => "string",
          "align" => "enum(left,center,right)",
          "border" => "string",
          "border-bottom" => "string",
          "border-left" => "string",
          "border-right" => "string",
          "border-top" => "string",
          "border-radius" => "string",
          "container-background-color" => "color",
          "fluid-on-mobile" => "boolean",
          "padding" => "unit(px,%){1,4}",
          "padding-bottom" => "unit(px,%)",
          "padding-left" => "unit(px,%)",
          "padding-right" => "unit(px,%)",
          "padding-top" => "unit(px,%)",
          "target" => "string",
          "width" => "unit(px)",
          "height" => "unit(px,auto)",
          "max-height" => "unit(px,%)",
          "font-size" => "unit(px)",
          "usemap" => "string"
        }
      end

      def get_styles
        width = get_content_width
        full_width = get_attribute("full-width") == "full-width"
        parsed = WidthParser.call(width)

        {
          img: {
            "border" => get_attribute("border"),
            "border-left" => get_attribute("border-left"),
            "border-right" => get_attribute("border-right"),
            "border-top" => get_attribute("border-top"),
            "border-bottom" => get_attribute("border-bottom"),
            "border-radius" => get_attribute("border-radius"),
            "display" => "block",
            "outline" => "none",
            "text-decoration" => "none",
            "height" => get_attribute("height"),
            "max-height" => get_attribute("max-height"),
            "min-width" => full_width ? "100%" : nil,
            "width" => "100%",
            "max-width" => full_width ? "100%" : nil,
            "font-size" => get_attribute("font-size")
          },
          td: {
            "width" => full_width ? nil : "#{parsed[:parsed_width]}#{parsed[:unit]}"
          },
          table: {
            "min-width" => full_width ? "100%" : nil,
            "max-width" => full_width ? "100%" : nil,
            "width" => full_width ? "#{parsed[:parsed_width]}#{parsed[:unit]}" : nil,
            "border-collapse" => "collapse",
            "border-spacing" => "0px"
          }
        }
      end

      def head_style(breakpoint)
        "\n    @media only screen and (max-width:#{MakeLowerBreakpoint.call(breakpoint)}) {\n      table.mj-full-width-mobile { width: 100% !important; }\n      td.mj-full-width-mobile { width: auto !important; }\n    }\n  "
      end

      def render
        fluid_class = get_attribute("fluid-on-mobile") ? "mj-full-width-mobile" : nil

        table_attrs = html_attributes(
          border: "0",
          cellpadding: "0",
          cellspacing: "0",
          role: "presentation",
          style: :table,
          class: fluid_class
        )

        td_attrs = html_attributes(
          style: :td,
          class: fluid_class
        )

        <<~HTML
          <table
            #{table_attrs}
          >
            <tbody>
              <tr>
                <td#{td_attrs}>
                  #{render_image}
                </td>
              </tr>
            </tbody>
          </table>
        HTML
      end

      private

      def get_content_width
        width = get_attribute("width")
        explicit_width = width ? width.to_i : Float::INFINITY
        box = get_box_widths[:box]
        [box, explicit_width].min
      end

      def render_image
        height = get_attribute("height")

        img_attrs = {
          alt: get_attribute("alt"),
          src: get_attribute("src"),
          srcset: get_attribute("srcset"),
          sizes: get_attribute("sizes"),
          style: :img,
          title: get_attribute("title"),
          width: get_content_width,
          usemap: get_attribute("usemap")
        }

        if height
          img_attrs[:height] = (height == "auto") ? height : height.to_i
        end

        img = <<~HTML.chomp
          <img
            #{html_attributes(img_attrs)}
          />
        HTML

        if get_attribute("href")
          a_attrs = html_attributes(
            href: get_attribute("href"),
            target: get_attribute("target"),
            rel: get_attribute("rel"),
            name: get_attribute("name"),
            title: get_attribute("title")
          )
          <<~HTML.chomp
            <a
              #{a_attrs}
            >
              #{img}
            </a>
          HTML
        else
          img
        end
      end
    end
  end
end
