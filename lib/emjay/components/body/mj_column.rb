# frozen_string_literal: true

require_relative "../../body_component"
require_relative "../../registry"
require_relative "../../helpers/width_parser"

module Emjay
  module Components
    class MjColumn < BodyComponent
      def self.component_name
        "mj-column"
      end

      def self.default_attributes
        {
          "direction" => "ltr",
          "vertical-align" => "top"
        }
      end

      def self.allowed_attributes
        {
          "background-color" => "color",
          "border" => "string",
          "border-bottom" => "string",
          "border-left" => "string",
          "border-radius" => "string",
          "border-right" => "string",
          "border-top" => "string",
          "direction" => "enum(ltr,rtl)",
          "inner-background-color" => "color",
          "padding-bottom" => "unit(px,%)",
          "padding-left" => "unit(px,%)",
          "padding-right" => "unit(px,%)",
          "padding-top" => "unit(px,%)",
          "inner-border" => "string",
          "inner-border-bottom" => "string",
          "inner-border-left" => "string",
          "inner-border-radius" => "string",
          "inner-border-right" => "string",
          "inner-border-top" => "string",
          "padding" => "unit(px,%){1,4}",
          "vertical-align" => "enum(top,bottom,middle)",
          "width" => "unit(px,%)"
        }
      end

      def get_child_context
        parent_width = @context[:container_width]
        non_raw_siblings = @props[:non_raw_siblings] || 1
        borders = get_shorthand_border_value("right") + get_shorthand_border_value("left")
        paddings = get_shorthand_attr_value("padding", "right") + get_shorthand_attr_value("padding", "left")
        inner_borders = get_shorthand_border_value("left", "inner-border") +
          get_shorthand_border_value("right", "inner-border")

        all_paddings = paddings + borders + inner_borders

        container_width = get_attribute("width") || "#{parent_width.to_f / non_raw_siblings}px"

        parsed = WidthParser.call(container_width, parse_float_to_int: false)

        container_width = if parsed[:unit] == "%"
          "#{(parent_width.to_f * parsed[:parsed_width]) / 100 - all_paddings}px"
        else
          "#{parsed[:parsed_width] - all_paddings}px"
        end

        @context.merge(container_width: container_width)
      end

      def get_styles
        has_br = has_border_radius?
        has_ibr = has_inner_border_radius?
        outlook_gutter = get_outlook_gutter_styles
        mobile_gutter = get_mobile_gutter_styles

        table_style = {
          "background-color" => get_attribute("background-color"),
          "border" => get_attribute("border"),
          "border-bottom" => get_attribute("border-bottom"),
          "border-left" => get_attribute("border-left"),
          "border-radius" => get_attribute("border-radius"),
          "border-right" => get_attribute("border-right"),
          "border-top" => get_attribute("border-top"),
          "vertical-align" => get_attribute("vertical-align"),
          **(has_br ? {"border-collapse" => "separate"} : {})
        }

        {
          div: {
            "font-size" => "0px",
            "text-align" => "left",
            "direction" => get_attribute("direction"),
            "display" => "inline-block",
            "vertical-align" => get_attribute("vertical-align"),
            "width" => get_mobile_width,
            **mobile_gutter
          },
          table: {
            **(has_gutter? ? {
              "background-color" => get_attribute("inner-background-color"),
              "border" => get_attribute("inner-border"),
              "border-bottom" => get_attribute("inner-border-bottom"),
              "border-left" => get_attribute("inner-border-left"),
              "border-radius" => get_attribute("inner-border-radius"),
              "border-right" => get_attribute("inner-border-right"),
              "border-top" => get_attribute("inner-border-top")
            } : table_style),
            **(has_ibr ? {"border-collapse" => "separate"} : {})
          },
          tdOutlook: {
            "vertical-align" => get_attribute("vertical-align"),
            "width" => get_width_as_pixel,
            **outlook_gutter
          },
          gutter: {
            **table_style,
            "padding" => get_attribute("padding"),
            "padding-top" => get_attribute("padding-top"),
            "padding-right" => get_attribute("padding-right"),
            "padding-bottom" => get_attribute("padding-bottom"),
            "padding-left" => get_attribute("padding-left")
          }
        }
      end

      def render
        classes_name = get_column_class.dup
        classes_name += " #{get_desktop_gutter_class_name}" if has_column_gutter?
        classes_name += " mj-outlook-group-fix"
        css_class = get_attribute("css-class")
        classes_name += " #{css_class}" if css_class

        <<~HTML
          <div#{html_attributes(class: classes_name, style: :div)}>
            #{has_gutter? ? render_gutter : render_column}
          </div>
        HTML
      end

      private

      def get_mobile_width
        container_width = @context[:container_width]
        non_raw_siblings = @props[:non_raw_siblings] || 1
        width = get_attribute("width")
        mobile_width = get_attribute("mobileWidth")

        return "100%" if mobile_width != "mobileWidth"

        return "#{(100 / non_raw_siblings).to_i}%" unless width

        parsed = WidthParser.call(width, parse_float_to_int: false)

        case parsed[:unit]
        when "%" then width
        else
          "#{(parsed[:parsed_width] / container_width.to_f) * 100}%"
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

      def get_column_class
        add_media_query = @context[:add_media_query]

        parsed = has_column_gutter? ? get_desktop_width : get_parsed_width
        normalized = (parsed[:unit] == "px") ? normalize_px_value(parsed[:parsed_width]) : parsed[:parsed_width]
        formatted = format_float(normalized).to_s.tr(".", "-")

        class_name = case parsed[:unit]
        when "%" then "mj-column-per-#{formatted}"
        else "mj-column-px-#{formatted}"
        end

        add_media_query&.call(class_name, {unit: parsed[:unit], parsed_width: normalized})

        if has_column_gutter? && !@context[:is_in_group]
          add_media_query&.call(get_desktop_gutter_class_name, {padding: get_desktop_padding})
        end

        class_name
      end

      # Formats a float to match JS toString() — strips trailing .0
      def format_float(value)
        (value == value.to_i) ? value.to_i : value
      end

      def has_column_gutter?
        gutter = @context[:gutter]
        !gutter.nil? && gutter != ""
      end

      def get_normalized_gutter_value(target_unit)
        gutter = @context[:gutter]
        return 0 if gutter.nil? || gutter == ""

        parsed = WidthParser.call(gutter, parse_float_to_int: false)
        parent_width = @context[:container_width]

        return parsed[:parsed_width] if parsed[:unit] == target_unit

        if target_unit == "%" && parsed[:unit] == "px"
          (parsed[:parsed_width] / parent_width.to_f) * 100
        elsif target_unit == "px" && parsed[:unit] == "%"
          (parent_width.to_f * parsed[:parsed_width]) / 100
        else
          parsed[:parsed_width]
        end
      end

      def get_desktop_unit
        get_parsed_width[:unit]
      end

      def get_desktop_width
        parsed = get_parsed_width
        return parsed unless has_column_gutter?

        sibling = @props[:sibling] || 1
        index = @props[:index] || 0
        unit = parsed[:unit]
        gutter = get_normalized_gutter_value(unit)
        reduction = (gutter * (sibling - 1)) / sibling.to_f
        reduced = [0, normalize_unit_value(parsed[:parsed_width] - reduction)].max

        if unit == "px"
          floor_width = reduced.floor
          fractional = reduced - floor_width
          extra = [0, [sibling, (sibling * fractional).round].min].max
          {parsed_width: floor_width + ((index < extra) ? 1 : 0), unit: unit}
        else
          {parsed_width: reduced, unit: unit}
        end
      end

      def get_desktop_gutter_class_name
        unit = get_desktop_unit
        gutter = get_normalized_gutter_value(unit)
        unit_token = (unit == "%") ? "per" : unit
        direction_token = (@context[:direction] == "rtl") ? "-rtl" : ""
        normalized = (unit == "px") ? normalize_px_value(gutter) : gutter
        gutter_token = normalize_unit_value(normalized).to_s.tr(".", "-")
        sibling = @props[:sibling] || 1
        index = @props[:index] || 0
        "mj-column-gutter-#{sibling}-#{index + 1}-#{unit_token}-#{gutter_token}#{direction_token}"
      end

      def get_desktop_padding_values(unit)
        first = @props[:first]
        last = @props[:last]
        sibling = @props[:sibling] || 1
        direction = @context[:direction]
        gutter = get_normalized_gutter_value(unit)
        normalized = (unit == "px") ? normalize_px_value(gutter) : gutter
        is_px = unit == "px"
        half_leading = is_px ? (normalized / 2.0).ceil : normalized / 2.0
        half_trailing = is_px ? (normalized / 2.0).floor : normalized / 2.0
        is_rtl = direction == "rtl"

        return {top: 0, right: 0, bottom: 0, left: 0} if sibling == 1

        if is_rtl
          {top: 0, right: first ? 0 : half_trailing, bottom: 0, left: last ? 0 : half_leading}
        else
          {top: 0, right: last ? 0 : half_leading, bottom: 0, left: first ? 0 : half_trailing}
        end
      end

      def get_mobile_padding_values
        first = @props[:first]
        last = @props[:last]
        gutter = get_normalized_gutter_value("%")
        half = gutter / 2.0
        {top: first ? 0 : half, right: 0, bottom: last ? 0 : half, left: 0}
      end

      def format_padding(top, right, bottom, left, unit)
        if unit == "px"
          "#{normalize_px_value(top)}px #{normalize_px_value(right)}px #{normalize_px_value(bottom)}px #{normalize_px_value(left)}px"
        else
          "#{normalize_unit_value(top)}#{unit} #{normalize_unit_value(right)}#{unit} #{normalize_unit_value(bottom)}#{unit} #{normalize_unit_value(left)}#{unit}"
        end
      end

      def get_desktop_padding
        unit = get_desktop_unit
        v = get_desktop_padding_values(unit)
        format_padding(v[:top], v[:right], v[:bottom], v[:left], unit)
      end

      def get_mobile_padding
        v = get_mobile_padding_values
        format_padding(v[:top], v[:right], v[:bottom], v[:left], "%")
      end

      def get_outlook_gutter_styles
        return {} unless has_column_gutter?
        {"padding" => get_desktop_padding_values("px").then { |v| format_padding(v[:top], v[:right], v[:bottom], v[:left], "px") }}
      end

      def get_mobile_gutter_styles
        return {} unless has_column_gutter?

        if @context[:is_in_group]
          {"padding" => get_desktop_padding}
        else
          {"padding" => get_mobile_padding}
        end
      end

      def normalize_unit_value(value)
        rounded = value.to_f.round(6)
        (rounded == rounded.to_i) ? rounded.to_i : rounded
      end

      def normalize_px_value(value)
        value.to_f.round
      end

      def has_border_radius?
        br = get_attribute("border-radius")
        br && !br.empty?
      end

      def has_inner_border_radius?
        ibr = get_attribute("inner-border-radius")
        ibr && !ibr.empty?
      end

      def has_gutter?
        %w[padding padding-bottom padding-left padding-right padding-top].any? { |attr|
          !get_attribute(attr).nil?
        }
      end

      def render_gutter
        has_br = has_border_radius?

        <<~HTML
          <table#{html_attributes(
            border: "0",
            cellpadding: "0",
            cellspacing: "0",
            role: "presentation",
            width: "100%",
            **(has_br ? {style: {"border-collapse" => "separate"}} : {})
          )}>
            <tbody>
              <tr>
                <td#{html_attributes(style: :gutter)}>
                  #{render_column}
                </td>
              </tr>
            </tbody>
          </table>
        HTML
      end

      def render_column
        children = @props[:children] || []

        <<~HTML
          <table#{html_attributes(
            border: "0",
            cellpadding: "0",
            cellspacing: "0",
            role: "presentation",
            style: :table,
            width: "100%"
          )}>
            <tbody>
              #{render_children(children, renderer: ->(component) {
                if component.class.raw_element?
                  component.render
                else
                  <<~CELL
                    <tr>
                      <td#{component.html_attributes(
                        align: component.get_attribute("align"),
                        class: component.get_attribute("css-class"),
                        style: {
                          "background" => component.get_attribute("container-background-color"),
                          "font-size" => "0px",
                          "padding" => component.get_attribute("padding"),
                          "padding-top" => component.get_attribute("padding-top"),
                          "padding-right" => component.get_attribute("padding-right"),
                          "padding-bottom" => component.get_attribute("padding-bottom"),
                          "padding-left" => component.get_attribute("padding-left"),
                          "word-break" => "break-word"
                        }
                      )}>
                        #{component.render}
                      </td>
                    </tr>
                  CELL
                end
              })}
            </tbody>
          </table>
        HTML
      end
    end
  end

  Registry.register(Components::MjColumn)
end
