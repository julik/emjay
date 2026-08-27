# frozen_string_literal: true

require_relative "../../body_component"
require_relative "../../helpers/conditional_tag"

module Emjay
  module Components
    class MjText < BodyComponent
      def self.component_name
        "mj-text"
      end

      def self.ending_tag?
        true
      end

      def self.default_attributes
        {
          "align" => "left",
          "color" => "#000000",
          "font-family" => "Ubuntu, Helvetica, Arial, sans-serif",
          "font-size" => "13px",
          "line-height" => "1",
          "padding" => "10px 25px"
        }
      end

      def self.allowed_attributes
        {
          "align" => "enum(left,right,center,justify)",
          "background-color" => "color",
          "color" => "color",
          "container-background-color" => "color",
          "font-family" => "string",
          "font-size" => "unit(px)",
          "font-style" => "string",
          "font-weight" => "string",
          "height" => "unit(px,%)",
          "letter-spacing" => "unitWithNegative(px,em)",
          "line-height" => "unit(px,%,)",
          "padding-bottom" => "unit(px,%)",
          "padding-left" => "unit(px,%)",
          "padding-right" => "unit(px,%)",
          "padding-top" => "unit(px,%)",
          "padding" => "unit(px,%){1,4}",
          "text-decoration" => "string",
          "text-transform" => "string",
          "vertical-align" => "enum(top,bottom,middle)"
        }
      end

      def get_styles
        {
          text: {
            "font-family" => get_attribute("font-family"),
            "font-size" => get_attribute("font-size"),
            "font-style" => get_attribute("font-style"),
            "font-weight" => get_attribute("font-weight"),
            "letter-spacing" => get_attribute("letter-spacing"),
            "line-height" => get_attribute("line-height"),
            "text-align" => get_attribute("align"),
            "text-decoration" => get_attribute("text-decoration"),
            "text-transform" => get_attribute("text-transform"),
            "color" => get_attribute("color"),
            "height" => get_attribute("height")
          }
        }
      end

      def render
        height = get_attribute("height")

        if height
          <<~HTML
            #{ConditionalTag.conditional_tag(
              "<table role=\"presentation\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\"><tr><td height=\"#{height}\" style=\"vertical-align:top;height:#{height};\">"
            )}
            #{render_content}
            #{ConditionalTag.conditional_tag(
              "</td></tr></table>"
            )}
          HTML
        else
          render_content
        end
      end

      private

      def render_content
        <<~HTML
          <div#{html_attributes(style: :text)}>#{get_content}</div>
        HTML
      end
    end
  end
end
