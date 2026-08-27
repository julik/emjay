# frozen_string_literal: true

require_relative "../../body_component"

module Emjay
  module Components
    class MjSocial < BodyComponent
      def self.component_name
        "mj-social"
      end

      def self.default_attributes
        {
          "align" => "center",
          "border-radius" => "3px",
          "color" => "#333333",
          "font-family" => "Ubuntu, Helvetica, Arial, sans-serif",
          "font-size" => "13px",
          "icon-size" => "20px",
          "inner-padding" => nil,
          "line-height" => "22px",
          "mode" => "horizontal",
          "padding" => "10px 25px",
          "text-decoration" => "none"
        }
      end

      def self.allowed_attributes
        {
          "align" => "enum(left,right,center)",
          "border-radius" => "string",
          "container-background-color" => "color",
          "color" => "color",
          "font-family" => "string",
          "font-size" => "unit(px)",
          "font-style" => "string",
          "font-weight" => "string",
          "icon-size" => "unit(px,%)",
          "icon-height" => "unit(px,%)",
          "icon-padding" => "unit(px,%){1,4}",
          "inner-padding" => "unit(px,%){1,4}",
          "line-height" => "unit(px,%,)",
          "mode" => "enum(horizontal,vertical)",
          "padding-bottom" => "unit(px,%)",
          "padding-left" => "unit(px,%)",
          "padding-right" => "unit(px,%)",
          "padding-top" => "unit(px,%)",
          "padding" => "unit(px,%){1,4}",
          "table-layout" => "enum(auto,fixed)",
          "text-padding" => "unit(px,%){1,4}",
          "text-decoration" => "string",
          "vertical-align" => "enum(top,bottom,middle)"
        }
      end

      def get_styles
        {
          tableVertical: {
            "margin" => "0px"
          }
        }
      end

      def render
        if get_attribute("mode") == "horizontal"
          render_horizontal
        else
          render_vertical
        end
      end

      private

      def get_social_element_attributes
        base = {}
        if get_attribute("inner-padding")
          base["padding"] = get_attribute("inner-padding")
        end

        %w[border-radius color font-family font-size font-weight font-style
          icon-size icon-height icon-padding text-padding line-height text-decoration].each_with_object(base) do |attr, result|
          val = get_attribute(attr)
          result[attr] = val unless val.nil?
        end
      end

      def render_horizontal
        children = @props[:children] || []

        align_attr = html_attributes(
          align: get_attribute("align"),
          border: "0",
          cellpadding: "0",
          cellspacing: "0",
          role: "presentation"
        )

        children_html = render_children(children,
          attributes: get_social_element_attributes,
          renderer: ->(component) {
            if component.class.raw_element?
              component.render
            else
              table_attrs = component.html_attributes(
                align: get_attribute("align"),
                border: "0",
                cellpadding: "0",
                cellspacing: "0",
                role: "presentation",
                style: {
                  "float" => "none",
                  "display" => "inline-table"
                }
              )
              <<~CHILD
                <!--[if mso | IE]>
                  <td>
                <![endif]-->
                  <table
                    #{table_attrs}
                  >
                    <tbody>
                      #{component.render}
                    </tbody>
                  </table>
                <!--[if mso | IE]>
                  </td>
                <![endif]-->
              CHILD
            end
          })

        <<~HTML
           <!--[if mso | IE]>
            <table
              #{align_attr}
            >
              <tr>
          <![endif]-->
          #{children_html}
          <!--[if mso | IE]>
              </tr>
            </table>
          <![endif]-->
        HTML
      end

      def render_vertical
        children = @props[:children] || []

        table_attrs = html_attributes(
          border: "0",
          cellpadding: "0",
          cellspacing: "0",
          role: "presentation",
          style: :tableVertical
        )

        <<~HTML
          <table
            #{table_attrs}
          >
            <tbody>
              #{render_children(children, attributes: get_social_element_attributes)}
            </tbody>
          </table>
        HTML
      end
    end
  end
end
