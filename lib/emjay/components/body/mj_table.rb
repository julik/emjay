# frozen_string_literal: true

require_relative "../../body_component"
require_relative "../../helpers/width_parser"

module Emjay
  module Components
    class MjTable < BodyComponent
      def self.component_name
        "mj-table"
      end

      def self.ending_tag?
        true
      end

      def self.default_attributes
        {
          "align" => "left",
          "border" => "none",
          "cellpadding" => "0",
          "cellspacing" => "0",
          "color" => "#000000",
          "font-family" => "Ubuntu, Helvetica, Arial, sans-serif",
          "font-size" => "13px",
          "line-height" => "22px",
          "padding" => "10px 25px",
          "table-layout" => "auto",
          "width" => "100%"
        }
      end

      def self.allowed_attributes
        {
          "align" => "enum(left,right,center)",
          "border" => "string",
          "cellpadding" => "integer",
          "cellspacing" => "integer",
          "container-background-color" => "color",
          "color" => "color",
          "font-family" => "string",
          "font-size" => "unit(px)",
          "font-weight" => "string",
          "line-height" => "unit(px,%,)",
          "padding-bottom" => "unit(px,%)",
          "padding-left" => "unit(px,%)",
          "padding-right" => "unit(px,%)",
          "padding-top" => "unit(px,%)",
          "padding" => "unit(px,%){1,4}",
          "role" => "enum(none,presentation)",
          "table-layout" => "enum(auto,fixed,initial,inherit)",
          "vertical-align" => "enum(top,bottom,middle)",
          "width" => "unit(px,%,auto)"
        }
      end

      def get_styles
        table_styles = {
          "color" => get_attribute("color"),
          "font-family" => get_attribute("font-family"),
          "font-size" => get_attribute("font-size"),
          "line-height" => get_attribute("line-height"),
          "table-layout" => get_attribute("table-layout"),
          "width" => get_attribute("width"),
          "border" => get_attribute("border")
        }

        table_styles["border-collapse"] = "separate" if has_cellspacing?

        {table: table_styles}
      end

      def render
        table_attrs = html_attributes(
          cellpadding: get_attribute("cellpadding"),
          cellspacing: get_attribute("cellspacing"),
          role: get_attribute("role"),
          width: get_width,
          border: "0",
          style: :table
        )
        <<~HTML
          <table
            #{table_attrs}
          >
            #{get_content}
          </table>
        HTML
      end

      private

      def get_width
        width = get_attribute("width")
        return width if width == "auto"

        parsed = WidthParser.call(width)
        (parsed[:unit] == "%") ? width : parsed[:parsed_width]
      end

      def has_cellspacing?
        cellspacing = get_attribute("cellspacing")
        numeric_value = cellspacing.to_s.gsub(/[^\d.]/, "").to_f
        !numeric_value.nan? && numeric_value > 0
      rescue
        false
      end
    end
  end
end
