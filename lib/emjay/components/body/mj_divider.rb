# frozen_string_literal: true

require_relative "../../body_component"
require_relative "../../helpers/width_parser"

module Emjay
  module Components
    class MjDivider < BodyComponent
      def self.component_name
        "mj-divider"
      end

      def self.default_attributes
        {
          "border-color" => "#000000",
          "border-style" => "solid",
          "border-width" => "4px",
          "padding" => "10px 25px",
          "width" => "100%",
          "align" => "center"
        }
      end

      def self.allowed_attributes
        {
          "border-color" => "color",
          "border-style" => "string",
          "border-width" => "unit(px)",
          "container-background-color" => "color",
          "padding" => "unit(px,%){1,4}",
          "padding-bottom" => "unit(px,%)",
          "padding-left" => "unit(px,%)",
          "padding-right" => "unit(px,%)",
          "padding-top" => "unit(px,%)",
          "width" => "unit(px,%)",
          "align" => "enum(left,center,right)"
        }
      end

      def get_styles
        compute_align = case get_attribute("align")
        when "left"
          "0px"
        when "right"
          "0px 0px 0px auto"
        else
          "0px auto"
        end

        border_top = ["style", "width", "color"].map { |attr|
          get_attribute("border-#{attr}")
        }.join(" ")

        p_styles = {
          "border-top" => border_top,
          "font-size" => "1px",
          "margin" => compute_align,
          "width" => get_attribute("width")
        }

        {
          p: p_styles,
          outlook: p_styles.merge("width" => get_outlook_width)
        }
      end

      def render
        p_attrs = html_attributes(style: :p)
        <<~HTML
          <p
            #{p_attrs}
          >
          </p>
          #{render_after}
        HTML
      end

      private

      def get_outlook_width
        container_width = @context[:container_width]
        padding_size = get_shorthand_attr_value("padding", "left") +
          get_shorthand_attr_value("padding", "right")

        width = get_attribute("width")
        parsed = WidthParser.call(width)

        case parsed[:unit]
        when "%"
          effective_width = container_width.to_i - padding_size
          percent_multiplier = parsed[:parsed_width].to_i / 100.0
          "#{(effective_width * percent_multiplier).to_i}px"
        when "px"
          width
        else
          "#{container_width.to_i - padding_size}px"
        end
      end

      def render_after
        outlook_attrs = html_attributes(
          align: get_attribute("align"),
          border: "0",
          cellpadding: "0",
          cellspacing: "0",
          style: :outlook,
          role: "presentation",
          width: get_outlook_width
        )
        <<~HTML
          <!--[if mso | IE]><table#{outlook_attrs} ><tr><td style="height:0;line-height:0;"> &nbsp;
          </td></tr></table><![endif]-->
        HTML
      end
    end
  end
end
