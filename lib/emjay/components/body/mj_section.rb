# frozen_string_literal: true

require_relative "../../body_component"
require_relative "../../helpers/suffix_css_classes"

module Emjay
  module Components
    class MjSection < BodyComponent
      def self.component_name
        "mj-section"
      end

      def self.allowed_attributes
        {
          "background-color" => "color",
          "background-url" => "string",
          "background-repeat" => "enum(repeat,no-repeat)",
          "background-size" => "string",
          "background-position" => "string",
          "background-position-x" => "string",
          "background-position-y" => "string",
          "border" => "string",
          "border-bottom" => "string",
          "border-left" => "string",
          "border-radius" => "string",
          "border-right" => "string",
          "border-top" => "string",
          "direction" => "enum(ltr,rtl)",
          "full-width" => "enum(full-width,false,)",
          "gutter" => "unit(px,%)",
          "padding" => "unit(px,%){1,4}",
          "padding-top" => "unit(px,%)",
          "padding-bottom" => "unit(px,%)",
          "padding-left" => "unit(px,%)",
          "padding-right" => "unit(px,%)",
          "text-align" => "enum(left,center,right)",
          "text-padding" => "unit(px,%){1,4}"
        }
      end

      def self.default_attributes
        {
          "background-repeat" => "repeat",
          "background-size" => "auto",
          "background-position" => "top center",
          "direction" => "ltr",
          "padding" => "20px 0",
          "text-align" => "center",
          "text-padding" => "4px 4px 4px 0"
        }
      end

      def get_child_context
        widths = get_box_widths
        @context.merge(
          container_width: "#{widths[:box]}px",
          gap: get_attribute("gap"),
          gutter: get_attribute("gutter"),
          direction: get_attribute("direction")
        )
      end

      def get_styles
        container_width = @context[:container_width]
        full_width = full_width?
        has_border_radius = has_border_radius?
        is_first = @props[:index] == 0

        background = if has_background?
          {
            "background" => get_background,
            "background-position" => get_background_string,
            "background-repeat" => get_attribute("background-repeat"),
            "background-size" => get_attribute("background-size")
          }
        else
          {
            "background" => get_attribute("background-color"),
            "background-color" => get_attribute("background-color")
          }
        end

        {
          tableFullwidth: {
            **(full_width ? background : {}),
            "width" => "100%"
          },
          table: {
            **(full_width ? {} : background),
            "width" => "100%",
            **(has_border_radius ? {"border-collapse" => "separate"} : {})
          },
          td: {
            "border" => get_attribute("border"),
            "border-bottom" => get_attribute("border-bottom"),
            "border-left" => get_attribute("border-left"),
            "border-right" => get_attribute("border-right"),
            "border-top" => get_attribute("border-top"),
            "border-radius" => get_attribute("border-radius"),
            "direction" => get_attribute("direction"),
            "font-size" => "0px",
            "padding" => get_attribute("padding"),
            "padding-bottom" => get_attribute("padding-bottom"),
            "padding-left" => get_attribute("padding-left"),
            "padding-right" => get_attribute("padding-right"),
            "padding-top" => get_attribute("padding-top"),
            "text-align" => get_attribute("text-align")
          },
          div: {
            **(full_width ? {} : background),
            "margin" => "0px auto",
            "max-width" => container_width,
            "border-radius" => get_attribute("border-radius"),
            **(has_border_radius ? {"overflow" => "hidden"} : {}),
            "margin-top" => ((!is_first) ? @context[:gap] : nil)
          },
          innerDiv: {
            "line-height" => "0",
            "font-size" => "0"
          }
        }
      end

      def render
        full_width? ? render_full_width : render_simple
      end

      private

      def full_width?
        get_attribute("full-width") == "full-width"
      end

      def has_background?
        !get_attribute("background-url").nil?
      end

      def has_border_radius?
        br = get_attribute("border-radius")
        br && !br.empty?
      end

      def get_background
        parts = [get_attribute("background-color")]
        if has_background?
          parts << "url('#{get_attribute("background-url")}')"
          parts << get_background_string
          parts << "/ #{get_attribute("background-size")}"
          parts << get_attribute("background-repeat")
        end
        parts.compact.reject(&:empty?).join(" ")
      end

      def get_background_string
        pos = get_background_position
        "#{pos[:pos_x]} #{pos[:pos_y]}"
      end

      def get_background_position
        x, y = parse_background_position
        {
          pos_x: get_attribute("background-position-x") || x,
          pos_y: get_attribute("background-position-y") || y
        }
      end

      def parse_background_position
        parts = (get_attribute("background-position") || "top center").split(" ")
        if parts.length == 1
          val = parts[0]
          if %w[top bottom].include?(val)
            return ["center", val]
          end
          return [val, "center"]
        end
        if parts.length == 2
          val1, val2 = parts
          if %w[top bottom].include?(val1) || (val1 == "center" && %w[left right].include?(val2))
            return [val2, val1]
          end
          return [val1, val2]
        end
        ["center", "top"]
      end

      def render_before
        container_width = @context[:container_width]
        bgcolor_attr = get_attribute("background-color") ? {bgcolor: get_attribute("background-color")} : {}
        is_first = @props[:index] == 0

        <<~HTML
          <!--[if mso | IE]>
          <table#{html_attributes(
            align: "center",
            border: "0",
            cellpadding: "0",
            cellspacing: "0",
            class: SuffixCssClasses.call(get_attribute("css-class"), "outlook"),
            role: "presentation",
            style: {
              "width" => container_width.to_s,
              "padding-top" => ((!is_first) ? @context[:gap] : nil)
            },
            width: container_width.to_i,
            **bgcolor_attr
          )}>
            <tr>
              <td style="line-height:0px;font-size:0px;mso-line-height-rule:exactly;">
          <![endif]-->
        HTML
      end

      def render_after
        <<~HTML
          <!--[if mso | IE]>
              </td>
            </tr>
          </table>
          <![endif]-->
        HTML
      end

      def render_wrapped_children
        children = @props[:children] || []

        rendered = render_children(children, renderer: ->(component) {
          if component.class.raw_element?
            component.render
          else
            <<~HTML
              <!--[if mso | IE]>
                <td#{component.html_attributes(
                  align: component.get_attribute("align"),
                  class: SuffixCssClasses.call(component.get_attribute("css-class"), "outlook"),
                  style: :tdOutlook
                )}>
              <![endif]-->
                #{component.render}
              <!--[if mso | IE]>
                </td>
              <![endif]-->
            HTML
          end
        })

        <<~HTML
          <!--[if mso | IE]>
            <tr>
          <![endif]-->
          #{rendered}
          <!--[if mso | IE]>
            </tr>
          <![endif]-->
        HTML
      end

      def render_section
        has_bg = has_background?

        <<~HTML
          <div#{html_attributes(
            class: (full_width? ? nil : get_attribute("css-class")),
            style: :div
          )}>
            #{"<div#{html_attributes(style: :innerDiv)}>" if has_bg}
            <table#{html_attributes(
              align: "center",
              background: (full_width? ? nil : get_attribute("background-url")),
              border: "0",
              cellpadding: "0",
              cellspacing: "0",
              role: "presentation",
              style: :table
            )}>
              <tbody>
                <tr>
                  <td#{html_attributes(style: :td)}>
                    <!--[if mso | IE]>
                      <table role="presentation" border="0" cellpadding="0" cellspacing="0">
                    <![endif]-->
                      #{render_wrapped_children}
                    <!--[if mso | IE]>
                      </table>
                    <![endif]-->
                  </td>
                </tr>
              </tbody>
            </table>
            #{"</div>" if has_bg}
          </div>
        HTML
      end

      def render_full_width
        content = if has_background?
          render_with_background(<<~HTML
            #{render_before}
            #{render_section}
            #{render_after}
          HTML
                                )
        else
          <<~HTML
            #{render_before}
            #{render_section}
            #{render_after}
          HTML
        end

        <<~HTML
          <table#{html_attributes(
            align: "center",
            class: get_attribute("css-class"),
            background: get_attribute("background-url"),
            border: "0",
            cellpadding: "0",
            cellspacing: "0",
            role: "presentation",
            style: :tableFullwidth
          )}>
            <tbody>
              <tr>
                <td>
                  #{content}
                </td>
              </tr>
            </tbody>
          </table>
        HTML
      end

      def render_simple
        section = render_section

        <<~HTML
          #{render_before}
          #{has_background? ? render_with_background(section) : section}
          #{render_after}
        HTML
      end

      def render_with_background(content)
        full_width = full_width?
        container_width = @context[:container_width]

        bg_pos = get_background_position
        bg_pos_x = bg_pos[:pos_x]
        bg_pos_y = bg_pos[:pos_y]

        # Convert named positions to percentages
        bg_pos_x = case bg_pos_x
        when "left" then "0%"
        when "center" then "50%"
        when "right" then "100%"
        else
          /^\d+(\.\d+)?%$/.match?(bg_pos_x) ? bg_pos_x : "50%"
        end

        bg_pos_y = case bg_pos_y
        when "top" then "0%"
        when "center" then "50%"
        when "bottom" then "100%"
        else
          /^\d+(\.\d+)?%$/.match?(bg_pos_y) ? bg_pos_y : "0%"
        end

        bg_repeat = get_attribute("background-repeat") == "repeat"

        v_origin_x, v_pos_x = compute_vml_position(bg_pos_x, bg_repeat, true)
        v_origin_y, v_pos_y = compute_vml_position(bg_pos_y, bg_repeat, false)

        v_size_attributes = {}
        bg_size = get_attribute("background-size")
        if bg_size == "cover" || bg_size == "contain"
          v_size_attributes = {
            size: "1,1",
            aspect: ((bg_size == "cover") ? "atleast" : "atmost")
          }
        elsif bg_size != "auto"
          parts = bg_size.split(" ")
          v_size_attributes = if parts.length == 1
            {size: bg_size, aspect: "atmost"}
          else
            {size: parts.join(",")}
          end
        end

        vml_type = (get_attribute("background-repeat") == "no-repeat") ? "frame" : "tile"
        if bg_size == "auto"
          vml_type = "tile"
          v_origin_x = 0.5
          v_pos_x = 0.5
          v_origin_y = 0
          v_pos_y = 0
        end

        <<~HTML
            <!--[if mso | IE]>
              <v:rect#{html_attributes(
                :style => full_width ? {"mso-width-percent" => "1000"} : {"width" => container_width},
                "xmlns:v" => "urn:schemas-microsoft-com:vml",
                :fill => "true",
                :stroke => "false"
              )}>
              <v:fill#{html_attributes(
                origin: "#{v_origin_x}, #{v_origin_y}",
                position: "#{v_pos_x}, #{v_pos_y}",
                src: get_attribute("background-url"),
                color: get_attribute("background-color"),
                type: vml_type,
                **v_size_attributes
              )} />
              <v:textbox style="mso-fit-shape-to-text:true" inset="0,0,0,0">
            <![endif]-->
                #{content}
              <!--[if mso | IE]>
              </v:textbox>
            </v:rect>
          <![endif]-->
        HTML
      end

      def compute_vml_position(pos_str, bg_repeat, is_x)
        if pos_str =~ /^(\d+(\.\d+)?)%$/
          decimal = $1.to_i / 100.0
          if bg_repeat
            [decimal, decimal]
          else
            val = (-50 + decimal * 100) / 100.0
            [val, val]
          end
        elsif bg_repeat
          default = is_x ? 0.5 : 0
          [default, default]
        else
          default = is_x ? 0 : -0.5
          [default, default]
        end
      end
    end
  end
end
