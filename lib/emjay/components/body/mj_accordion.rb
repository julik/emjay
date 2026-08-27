# frozen_string_literal: true

require_relative "../../body_component"

module Emjay
  module Components
    class MjAccordion < BodyComponent
      def self.component_name
        "mj-accordion"
      end

      def self.default_attributes
        {
          "border" => "2px solid black",
          "font-family" => "Ubuntu, Helvetica, Arial, sans-serif",
          "icon-align" => "middle",
          "icon-wrapped-url" => "https://i.imgur.com/bIXv1bk.png",
          "icon-wrapped-alt" => "+",
          "icon-unwrapped-url" => "https://i.imgur.com/w4uTygT.png",
          "icon-unwrapped-alt" => "-",
          "icon-position" => "right",
          "icon-height" => "32px",
          "icon-width" => "32px",
          "padding" => "10px 25px"
        }
      end

      def self.allowed_attributes
        {
          "container-background-color" => "color",
          "border" => "string",
          "font-family" => "string",
          "icon-align" => "enum(top,middle,bottom)",
          "icon-width" => "unit(px,%)",
          "icon-height" => "unit(px,%)",
          "icon-wrapped-url" => "string",
          "icon-wrapped-alt" => "string",
          "icon-unwrapped-url" => "string",
          "icon-unwrapped-alt" => "string",
          "icon-position" => "enum(left,right)",
          "padding-bottom" => "unit(px,%)",
          "padding-left" => "unit(px,%)",
          "padding-right" => "unit(px,%)",
          "padding-top" => "unit(px,%)",
          "padding" => "unit(px,%){1,4}"
        }
      end

      def head_style(_breakpoint = nil)
        "\n      noinput.mj-accordion-checkbox { display:block!important; }\n\n      @media yahoo, only screen and (min-width:0) {\n        .mj-accordion-element { display:block; }\n        .mj-accordion-checkbox[type=\"checkbox\"], .mj-accordion-less { display:none!important; }\n        .mj-accordion-checkbox[type=\"checkbox\"] + * .mj-accordion-title { cursor:pointer; touch-action:manipulation; -webkit-user-select:none; -moz-user-select:none; user-select:none; }\n        .mj-accordion-checkbox[type=\"checkbox\"] + * .mj-accordion-content { overflow:hidden; display:none; }\n        .mj-accordion-checkbox[type=\"checkbox\"] + * .mj-accordion-more { display:block!important; }\n        .mj-accordion-checkbox:checked + * .mj-accordion-content { display:block; }\n        .mj-accordion-checkbox:checked + * .mj-accordion-more { display:none!important; }\n        .mj-accordion-checkbox:checked + * .mj-accordion-less { display:block!important; }\n      }\n\n      .moz-text-html input.mj-accordion-checkbox + * .mj-accordion-title { cursor: auto; touch-action: auto; -webkit-user-select: auto; -moz-user-select: auto; user-select: auto; }\n      .moz-text-html input.mj-accordion-checkbox + * .mj-accordion-content { overflow: hidden; display: block; }\n      .moz-text-html input.mj-accordion-checkbox + * .mj-accordion-ico { display: none; }\n\n      @goodbye { @gmail }\n    "
      end

      def get_styles
        {
          table: {
            "width" => "100%",
            "border-collapse" => "collapse",
            "border" => get_attribute("border"),
            "border-bottom" => "none",
            "font-family" => get_attribute("font-family")
          }
        }
      end

      def get_child_context
        @context.merge(accordionFontFamily: get_attribute("font-family"))
      end

      def render
        children = @props[:children] || []

        children_attr = %w[border icon-align icon-width icon-height icon-position
          icon-wrapped-url icon-wrapped-alt icon-unwrapped-url icon-unwrapped-alt].each_with_object({}) do |attr, hash|
          hash[attr] = get_attribute(attr)
        end

        table_attrs = html_attributes(
          cellspacing: "0",
          cellpadding: "0",
          class: "mj-accordion",
          style: :table
        )

        <<~HTML
          <table
            #{table_attrs}
          >
            <tbody>
              #{render_children(children, attributes: children_attr)}
            </tbody>
          </table>
        HTML
      end
    end
  end
end
