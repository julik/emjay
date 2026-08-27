# frozen_string_literal: true

require_relative "../../body_component"
require_relative "../../helpers/width_parser"

module Emjay
  module Components
    class MjGroup < BodyComponent
      def self.component_name
        "mj-group"
      end

      def self.allowed_attributes
        {
          "background-color" => "color",
          "direction" => "enum(ltr,rtl)",
          "vertical-align" => "enum(top,bottom,middle)",
          "width" => "unit(px,%)"
        }
      end

      def self.default_attributes
        {"direction" => "ltr"}
      end

      def get_child_context
        parent_width = @context[:container_width]
        non_raw_siblings = @props[:non_raw_siblings] || 1
        padding_size = get_shorthand_attr_value("padding", "left") +
          get_shorthand_attr_value("padding", "right")

        container_width = get_attribute("width") ||
          "#{parent_width.to_f / non_raw_siblings}px"

        parsed = WidthParser.call(container_width, parse_float_to_int: false)

        container_width = if parsed[:unit] == "%"
          "#{(parent_width.to_f * parsed[:parsed_width]) / 100 - padding_size}px"
        else
          "#{parsed[:parsed_width] - padding_size}px"
        end

        children = @props[:children] || []

        @context.merge(
          container_width: container_width,
          non_raw_siblings: children.length
        )
      end

      def get_styles
        {
          div: {
            "font-size" => "0",
            "line-height" => "0",
            "text-align" => "left",
            "display" => "inline-block",
            "width" => "100%",
            "direction" => get_attribute("direction"),
            "vertical-align" => get_attribute("vertical-align"),
            "background-color" => get_attribute("background-color")
          },
          tdOutlook: {
            "vertical-align" => get_attribute("vertical-align"),
            "width" => get_width_as_pixel
          }
        }
      end

      def render
        children = @props[:children] || []
        non_raw_siblings = @props[:non_raw_siblings] || 1

        group_context = get_child_context
        group_width = group_context[:container_width]
        container_width = @context[:container_width]

        get_element_width = ->(width) {
          unless width
            return "#{container_width.to_i / non_raw_siblings.to_i}px"
          end

          parsed = WidthParser.call(width, parse_float_to_int: false)

          if parsed[:unit] == "%"
            "#{(100 * parsed[:parsed_width]) / group_width.to_f}px"
          else
            "#{parsed[:parsed_width]}#{parsed[:unit]}"
          end
        }

        classes_name = "#{get_column_class} mj-outlook-group-fix"
        css_class = get_attribute("css-class")
        classes_name += " #{css_class}" if css_class

        <<~HTML
          <div#{html_attributes(class: classes_name, style: :div)}>
            <!--[if mso | IE]>
            <table#{html_attributes(
              bgcolor: ((get_attribute("background-color") == "none") ? nil : get_attribute("background-color")),
              border: "0",
              cellpadding: "0",
              cellspacing: "0",
              role: "presentation"
            )}>
              <tr>
            <![endif]-->
              #{render_children(children, attributes: {"mobileWidth" => "mobileWidth"}, renderer: ->(component) {
                if component.class.raw_element?
                  component.render
                else
                  comp_width = if component.respond_to?(:get_width_as_pixel, true)
                    begin
                      component.send(:get_width_as_pixel)
                    rescue
                      component.get_attribute("width")
                    end
                  else
                    component.get_attribute("width")
                  end

                  <<~CELL
                    <!--[if mso | IE]>
                    <td#{component.html_attributes(
                      style: {
                        "align" => component.get_attribute("align"),
                        "vertical-align" => component.get_attribute("vertical-align"),
                        "width" => get_element_width.call(comp_width)
                      }
                    )}>
                    <![endif]-->
                      #{component.render}
                    <!--[if mso | IE]>
                    </td>
                    <![endif]-->
                  CELL
                end
              })}
            <!--[if mso | IE]>
              </tr>
              </table>
            <![endif]-->
          </div>
        HTML
      end

      private

      def get_parsed_width(to_string = false)
        non_raw_siblings = @props[:non_raw_siblings] || 1
        width = get_attribute("width") || "#{100.0 / non_raw_siblings}%"

        parsed = WidthParser.call(width, parse_float_to_int: false)

        if to_string
          "#{format_float(parsed[:parsed_width])}#{parsed[:unit]}"
        else
          parsed
        end
      end

      def get_width_as_pixel
        container_width = @context[:container_width]
        parsed = WidthParser.call(get_parsed_width(true), parse_float_to_int: false)

        if parsed[:unit] == "%"
          "#{format_float((container_width.to_f * parsed[:parsed_width]) / 100)}px"
        else
          "#{format_float(parsed[:parsed_width])}px"
        end
      end

      def get_column_class
        add_media_query = @context[:add_media_query]
        parsed = get_parsed_width

        class_name = case parsed[:unit]
        when "%"
          "mj-column-per-#{parsed[:parsed_width].to_i}"
        else
          "mj-column-px-#{parsed[:parsed_width].to_i}"
        end

        add_media_query&.call(class_name, parsed)
        class_name
      end

      def format_float(value)
        (value == value.to_i) ? value.to_i : value
      end
    end
  end
end
