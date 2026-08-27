# frozen_string_literal: true

require_relative "../../body_component"

module Emjay
  module Components
    class MjSpacer < BodyComponent
      def self.component_name
        "mj-spacer"
      end

      def self.default_attributes
        {
          "height" => "20px"
        }
      end

      def self.allowed_attributes
        {
          "border" => "string",
          "border-bottom" => "string",
          "border-left" => "string",
          "border-right" => "string",
          "border-top" => "string",
          "container-background-color" => "color",
          "padding-bottom" => "unit(px,%)",
          "padding-left" => "unit(px,%)",
          "padding-right" => "unit(px,%)",
          "padding-top" => "unit(px,%)",
          "padding" => "unit(px,%){1,4}",
          "height" => "unit(px,%)"
        }
      end

      def get_styles
        {
          div: {
            "height" => get_attribute("height"),
            "line-height" => get_attribute("height")
          }
        }
      end

      def render
        div_attrs = html_attributes(style: :div)
        <<~HTML
          <div
            #{div_attrs}
          >&#8202;</div>
        HTML
      end
    end
  end
end
