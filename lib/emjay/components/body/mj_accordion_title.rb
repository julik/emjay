# frozen_string_literal: true

require_relative "../../body_component"
require_relative "../../helpers/conditional_tag"

module Emjay
  module Components
    class MjAccordionTitle < BodyComponent
      def self.component_name
        "mj-accordion-title"
      end

      def self.ending_tag?
        true
      end

      def self.default_attributes
        {
          "font-size" => "13px",
          "padding" => "16px"
        }
      end

      def self.allowed_attributes
        {
          "background-color" => "color",
          "color" => "color",
          "font-size" => "unit(px)",
          "font-family" => "string",
          "font-weight" => "string",
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
            "width" => "100%",
            "background-color" => get_attribute("background-color"),
            "color" => get_attribute("color"),
            "font-size" => get_attribute("font-size"),
            "font-family" => resolve_font_family,
            "font-weight" => get_attribute("font-weight"),
            "padding" => get_attribute("padding"),
            "padding-bottom" => get_attribute("padding-bottom"),
            "padding-left" => get_attribute("padding-left"),
            "padding-right" => get_attribute("padding-right"),
            "padding-top" => get_attribute("padding-top")
          },
          table: {
            "width" => "100%",
            "border-bottom" => get_attribute("border")
          },
          td2: {
            "padding" => "16px",
            "background" => get_attribute("background-color"),
            "vertical-align" => get_attribute("icon-align")
          },
          img: {
            "display" => "none",
            "width" => get_attribute("icon-width"),
            "height" => get_attribute("icon-height")
          }
        }
      end

      def render
        content_elements = [render_title, render_icons]
        content = if get_attribute("icon-position") == "right"
          content_elements
        else
          content_elements.reverse
        end.join("\n")

        table_attrs = html_attributes(
          cellspacing: "0",
          cellpadding: "0",
          style: :table
        )

        <<~HTML
          <div#{html_attributes(class: "mj-accordion-title")}>
            <table
              #{table_attrs}
            >
              <tbody>
                <tr>
                  #{content}
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

      def render_title
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

      def render_icons
        td2_attrs = html_attributes(
          class: "mj-accordion-ico",
          style: :td2
        )

        more_attrs = html_attributes(
          src: get_attribute("icon-wrapped-url"),
          alt: get_attribute("icon-wrapped-alt"),
          class: "mj-accordion-more",
          style: :img
        )

        less_attrs = html_attributes(
          src: get_attribute("icon-unwrapped-url"),
          alt: get_attribute("icon-unwrapped-alt"),
          class: "mj-accordion-less",
          style: :img
        )

        ConditionalTag.conditional_tag(
          <<~ICON,
            <td
              #{td2_attrs}
            >
              <img
                #{more_attrs}
              />
              <img
                #{less_attrs}
              />
            </td>
          ICON
          negation: true
        )
      end
    end
  end
end
