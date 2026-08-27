# frozen_string_literal: true

require_relative "../../body_component"
require_relative "../../helpers/conditional_tag"

module Emjay
  module Components
    class MjAccordionElement < BodyComponent
      def self.component_name
        "mj-accordion-element"
      end

      def self.default_attributes
        {}
      end

      def self.allowed_attributes
        {
          "background-color" => "color",
          "border" => "string",
          "font-family" => "string",
          "icon-align" => "enum(top,middle,bottom)",
          "icon-width" => "unit(px,%)",
          "icon-height" => "unit(px,%)",
          "icon-wrapped-url" => "string",
          "icon-wrapped-alt" => "string",
          "icon-unwrapped-url" => "string",
          "icon-unwrapped-alt" => "string",
          "icon-position" => "enum(left,right)"
        }
      end

      def get_styles
        {
          td: {
            "padding" => "0px",
            "background-color" => get_attribute("background-color")
          },
          label: {
            "font-size" => "13px",
            "font-family" => get_attribute("font-family")
          },
          input: {
            "display" => "none"
          }
        }
      end

      def get_child_context
        @context.merge(elementFontFamily: get_attribute("font-family"))
      end

      def render
        tr_attrs = html_attributes(class: get_attribute("css-class"))
        td_attrs = html_attributes(style: :td)
        label_attrs = html_attributes(
          class: "mj-accordion-element",
          style: :label
        )
        input_attrs = html_attributes(
          class: "mj-accordion-checkbox",
          type: "checkbox",
          style: :input
        )

        input_html = ConditionalTag.conditional_tag(
          "<input#{input_attrs} />",
          negation: true
        )

        <<~HTML
          <tr
            #{tr_attrs}
          >
            <td#{td_attrs}>
              <label
                #{label_attrs}
              >
                #{input_html}
                <div>
                  #{handle_missing_children}
                </div>
              </label>
            </td>
          </tr>
        HTML
      end

      private

      def handle_missing_children
        children = @props[:children] || []
        children_attr = %w[border icon-align icon-width icon-height icon-position
          icon-wrapped-url icon-wrapped-alt icon-unwrapped-url icon-unwrapped-alt].each_with_object({}) do |attr, hash|
          hash[attr] = get_attribute(attr)
        end

        result = []

        has_title = children.any? { |c| c[:tag_name] == "mj-accordion-title" }
        unless has_title
          title_component = Components::MjAccordionTitle.new(
            attributes: children_attr,
            context: get_child_context
          )
          result << title_component.render
        end

        result << render_children(children, attributes: children_attr)

        has_text = children.any? { |c| c[:tag_name] == "mj-accordion-text" }
        unless has_text
          text_component = Components::MjAccordionText.new(
            attributes: children_attr,
            context: get_child_context
          )
          result << text_component.render
        end

        result.join("\n")
      end
    end
  end
end
