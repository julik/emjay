# frozen_string_literal: true

require_relative "../../body_component"
require_relative "../../helpers/width_parser"

module Emjay
  module Components
    class MjHero < BodyComponent
      def self.component_name
        "mj-hero"
      end

      def self.default_attributes
        {
          "mode" => "fixed-height",
          "height" => "0px",
          "background-url" => nil,
          "background-position" => "center center",
          "padding" => "0px",
          "padding-bottom" => nil,
          "padding-left" => nil,
          "padding-right" => nil,
          "padding-top" => nil,
          "background-color" => "#ffffff",
          "vertical-align" => "top"
        }
      end

      def self.allowed_attributes
        {
          "mode" => "string",
          "height" => "unit(px,%)",
          "background-url" => "string",
          "background-width" => "unit(px,%)",
          "background-height" => "unit(px,%)",
          "background-position" => "string",
          "border-radius" => "string",
          "inner-background-color" => "color",
          "inner-padding" => "unit(px,%){1,4}",
          "inner-padding-top" => "unit(px,%)",
          "inner-padding-left" => "unit(px,%)",
          "inner-padding-right" => "unit(px,%)",
          "inner-padding-bottom" => "unit(px,%)",
          "padding" => "unit(px,%){1,4}",
          "padding-bottom" => "unit(px,%)",
          "padding-left" => "unit(px,%)",
          "padding-right" => "unit(px,%)",
          "padding-top" => "unit(px,%)",
          "background-color" => "color",
          "vertical-align" => "enum(top,bottom,middle)"
        }
      end

      def get_child_context
        container_width = @context[:container_width]
        padding_size = get_shorthand_attr_value("padding", "left") +
          get_shorthand_attr_value("padding", "right")

        current = "#{container_width.to_f}px"
        parsed = WidthParser.call(current, parse_float_to_int: false)

        current = if parsed[:unit] == "%"
          "#{(container_width.to_f * parsed[:parsed_width]) / 100 - padding_size}px"
        else
          "#{parsed[:parsed_width] - padding_size}px"
        end

        @context.merge(container_width: current)
      end

      def get_styles
        container_width = @context[:container_width]
        current_container_width = get_child_context[:container_width]

        bg_height_raw = get_attribute("background-height")
        bg_width_raw = get_attribute("background-width")
        bg_height = bg_height_raw.to_i
        bg_width_val = bg_width_raw.to_i
        background_ratio = if bg_height_raw.nil? || bg_width_raw.nil? || bg_width_val == 0
          "NaN"
        else
          (bg_height.to_f / bg_width_val * 100).round
        end

        width = get_attribute("background-width") || container_width

        {
          div: {
            "margin" => "0 auto",
            "max-width" => container_width
          },
          table: {
            "width" => "100%"
          },
          tr: {
            "vertical-align" => "top"
          },
          "td-fluid": {
            "width" => "0.01%",
            "padding-bottom" => "#{background_ratio}%",
            "mso-padding-bottom-alt" => "0"
          },
          "outlook-table": {
            "width" => container_width
          },
          "outlook-td": {
            "line-height" => "0",
            "font-size" => "0",
            "mso-line-height-rule" => "exactly"
          },
          "outlook-inner-table": {
            "width" => current_container_width
          },
          "outlook-image": {
            "border" => "0",
            "height" => get_attribute("background-height"),
            "mso-position-horizontal" => "center",
            "position" => "absolute",
            "top" => "0",
            "width" => width,
            "z-index" => "-3"
          },
          "outlook-inner-td": {
            "background-color" => get_attribute("inner-background-color"),
            "padding" => get_attribute("inner-padding"),
            "padding-top" => get_attribute("inner-padding-top"),
            "padding-left" => get_attribute("inner-padding-left"),
            "padding-right" => get_attribute("inner-padding-right"),
            "padding-bottom" => get_attribute("inner-padding-bottom")
          },
          "inner-div": {
            "background-color" => get_attribute("inner-background-color"),
            "float" => get_attribute("align"),
            "margin" => "0px auto",
            "width" => get_attribute("width"),
            "padding" => get_attribute("inner-padding"),
            "padding-top" => get_attribute("inner-padding-top"),
            "padding-left" => get_attribute("inner-padding-left"),
            "padding-right" => get_attribute("inner-padding-right"),
            "padding-bottom" => get_attribute("inner-padding-bottom")
          },
          "inner-table": {
            "width" => "100%",
            "margin" => "0px"
          }
        }
      end

      def render
        container_width = @context[:container_width]

        outlook_table_attrs = html_attributes(
          align: "center",
          border: "0",
          cellpadding: "0",
          cellspacing: "0",
          role: "presentation",
          style: "outlook-table",
          width: container_width.to_i
        )

        outlook_td_attrs = html_attributes(style: "outlook-td")
        outlook_image_attrs = html_attributes(
          style: "outlook-image",
          src: get_attribute("background-url"),
          "xmlns:v": "urn:schemas-microsoft-com:vml"
        )

        div_attrs = html_attributes(
          align: get_attribute("align"),
          class: get_attribute("css-class"),
          style: :div
        )

        table_attrs = html_attributes(
          border: "0",
          cellpadding: "0",
          cellspacing: "0",
          role: "presentation",
          style: :table
        )

        tr_attrs = html_attributes(style: :tr)

        <<~HTML
            <!--[if mso | IE]>
              <table
                #{outlook_table_attrs}
              >
                <tr>
                  <td#{outlook_td_attrs}>
                    <v:image
                      #{outlook_image_attrs}
                    />
            <![endif]-->
            <div
              #{div_attrs}
            >
              <table
                #{table_attrs}
              >
                <tbody>
                  <tr
                    #{tr_attrs}
                  >
                    #{render_mode}
                  </tr>
                </tbody>
            </table>
          </div>
          <!--[if mso | IE]>
                </td>
              </tr>
            </table>
          <![endif]-->
        HTML
      end

      private

      def get_background
        parts = [get_attribute("background-color")]
        if get_attribute("background-url")
          parts << "url('#{get_attribute("background-url")}')"
          parts << "no-repeat"
          parts << "#{get_attribute("background-position")} / cover"
        end
        parts.compact.reject(&:empty?).join(" ")
      end

      def render_content
        current_container_width = get_child_context[:container_width]

        outlook_inner_table_attrs = html_attributes(
          align: get_attribute("align"),
          border: "0",
          cellpadding: "0",
          cellspacing: "0",
          style: "outlook-inner-table",
          width: current_container_width.to_i
        )

        outlook_inner_td_attrs = html_attributes(style: "outlook-inner-td")

        inner_div_attrs = html_attributes(
          align: get_attribute("align"),
          class: "mj-hero-content",
          style: "inner-div"
        )

        inner_table_attrs = html_attributes(
          border: "0",
          cellpadding: "0",
          cellspacing: "0",
          role: "presentation",
          style: "inner-table"
        )

        children = @props[:children] || []

        children_html = render_children(children,
          renderer: ->(component) {
            if component.class.raw_element?
              component.render
            else
              td_attrs = component.html_attributes(
                align: component.get_attribute("align"),
                background: component.get_attribute("container-background-color"),
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
              )
              <<~CHILD
                <tr>
                  <td
                    #{td_attrs}
                  >
                    #{component.render}
                  </td>
                </tr>
              CHILD
            end
          })

        <<~HTML
          <!--[if mso | IE]>
            <table
              #{outlook_inner_table_attrs}
            >
              <tr>
                <td#{outlook_inner_td_attrs}>
          <![endif]-->
          <div
            #{inner_div_attrs}
          >
            <table
              #{inner_table_attrs}
            >
              <tbody>
                <tr>
                  <td#{html_attributes(style: "inner-td")} >
                    <table
                      #{inner_table_attrs}
                    >
                      <tbody>
                        #{children_html}
                      </tbody>
                    </table>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          <!--[if mso | IE]>
                </td>
              </tr>
            </table>
          <![endif]-->
        HTML
      end

      def render_mode
        common_style = {
          "background" => get_background,
          "background-position" => get_attribute("background-position"),
          "background-repeat" => "no-repeat",
          "border-radius" => get_attribute("border-radius"),
          "padding" => get_attribute("padding"),
          "padding-top" => get_attribute("padding-top"),
          "padding-left" => get_attribute("padding-left"),
          "padding-right" => get_attribute("padding-right"),
          "padding-bottom" => get_attribute("padding-bottom"),
          "vertical-align" => get_attribute("vertical-align")
        }

        case get_attribute("mode")
        when "fluid-height"
          magic_td_attrs = html_attributes(style: "td-fluid")
          td_attrs = html_attributes(
            background: get_attribute("background-url"),
            style: common_style
          )
          <<~HTML
            <td#{magic_td_attrs} />
            <td#{td_attrs}>
              #{render_content}
            </td>
            <td#{magic_td_attrs} />
          HTML
        else # fixed-height
          height = get_attribute("height").to_i -
            get_shorthand_attr_value("padding", "top") -
            get_shorthand_attr_value("padding", "bottom")

          td_attrs = html_attributes(
            background: get_attribute("background-url"),
            style: common_style.merge("height" => "#{height}px"),
            height: height
          )
          <<~HTML
            <td
              #{td_attrs}
            >
              #{render_content}
            </td>
          HTML
        end
      end
    end
  end
end
