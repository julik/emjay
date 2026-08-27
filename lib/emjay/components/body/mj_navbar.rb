# frozen_string_literal: true

require_relative "../../body_component"
require_relative "../../helpers/conditional_tag"
require_relative "../../helpers/make_lower_breakpoint"
require_relative "../../helpers/gen_random_hex_string"

module Emjay
  module Components
    class MjNavbar < BodyComponent
      def self.component_name
        "mj-navbar"
      end

      def self.default_attributes
        {
          "align" => "center",
          "base-url" => nil,
          "hamburger" => nil,
          "ico-align" => "center",
          "ico-open" => "&#9776;",
          "ico-close" => "&#8855;",
          "ico-color" => "#000000",
          "ico-font-size" => "30px",
          "ico-font-family" => "Ubuntu, Helvetica, Arial, sans-serif",
          "ico-text-transform" => "uppercase",
          "ico-padding" => "10px",
          "ico-text-decoration" => "none",
          "ico-line-height" => "30px"
        }
      end

      def self.allowed_attributes
        {
          "align" => "enum(left,center,right)",
          "base-url" => "string",
          "hamburger" => "string",
          "ico-align" => "enum(left,center,right)",
          "ico-open" => "string",
          "ico-close" => "string",
          "ico-color" => "color",
          "ico-font-size" => "unit(px,%)",
          "ico-font-family" => "string",
          "ico-text-transform" => "string",
          "ico-padding" => "unit(px,%){1,4}",
          "ico-padding-left" => "unit(px,%)",
          "ico-padding-top" => "unit(px,%)",
          "ico-padding-right" => "unit(px,%)",
          "ico-padding-bottom" => "unit(px,%)",
          "padding" => "unit(px,%){1,4}",
          "padding-left" => "unit(px,%)",
          "padding-top" => "unit(px,%)",
          "padding-right" => "unit(px,%)",
          "padding-bottom" => "unit(px,%)",
          "ico-text-decoration" => "string",
          "ico-line-height" => "unit(px,%,)"
        }
      end

      def head_style(breakpoint)
        "\n      noinput.mj-menu-checkbox { display:block!important; max-height:none!important; visibility:visible!important; }\n\n      @media only screen and (max-width:#{MakeLowerBreakpoint.call(breakpoint)}) {\n        .mj-menu-checkbox[type=\"checkbox\"] ~ .mj-inline-links { display:none!important; }\n        .mj-menu-checkbox[type=\"checkbox\"]:checked ~ .mj-inline-links,\n        .mj-menu-checkbox[type=\"checkbox\"] ~ .mj-menu-trigger { display:block!important; max-width:none!important; max-height:none!important; font-size:inherit!important; }\n        .mj-menu-checkbox[type=\"checkbox\"] ~ .mj-inline-links > a { display:block!important; }\n        .mj-menu-checkbox[type=\"checkbox\"]:checked ~ .mj-menu-trigger .mj-menu-icon-close { display:block!important; }\n        .mj-menu-checkbox[type=\"checkbox\"]:checked ~ .mj-menu-trigger .mj-menu-icon-open { display:none!important; }\n      }\n    "
      end

      def get_styles
        {
          div: {},
          label: {
            "display" => "block",
            "cursor" => "pointer",
            "mso-hide" => "all",
            "-moz-user-select" => "none",
            "user-select" => "none",
            "color" => get_attribute("ico-color"),
            "font-size" => get_attribute("ico-font-size"),
            "font-family" => get_attribute("ico-font-family"),
            "text-transform" => get_attribute("ico-text-transform"),
            "text-decoration" => get_attribute("ico-text-decoration"),
            "line-height" => get_attribute("ico-line-height"),
            "padding" => get_attribute("ico-padding"),
            "padding-top" => get_attribute("ico-padding-top"),
            "padding-right" => get_attribute("ico-padding-right"),
            "padding-bottom" => get_attribute("ico-padding-bottom"),
            "padding-left" => get_attribute("ico-padding-left")
          },
          trigger: {
            "display" => "none",
            "max-height" => "0px",
            "max-width" => "0px",
            "font-size" => "0px",
            "overflow" => "hidden"
          },
          icoOpen: {
            "mso-hide" => "all"
          },
          icoClose: {
            "display" => "none",
            "mso-hide" => "all"
          }
        }
      end

      def render
        hamburger_html = (get_attribute("hamburger") == "hamburger") ? render_hamburger : ""

        div_attrs = html_attributes(
          class: "mj-inline-links",
          style: :div
        )

        children = @props[:children] || []
        children_html = render_children(children,
          attributes: {"navbarBaseUrl" => get_attribute("base-url")})

        align = get_attribute("align")

        <<~HTML
          #{hamburger_html}
            <div
              #{div_attrs}
            >
            #{ConditionalTag.conditional_tag("<table role=\"presentation\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" align=\"#{align}\"><tr>")}
              #{children_html}
              #{ConditionalTag.conditional_tag("</tr></table>")}
            </div>
        HTML
      end

      private

      def render_hamburger
        label_key = GenRandomHexString.call(16)

        input_html = ConditionalTag.mso_conditional_tag(
          "<input type=\"checkbox\" id=\"#{label_key}\" class=\"mj-menu-checkbox\" style=\"display:none !important; max-height:0; visibility:hidden;\" />",
          negation: true
        )

        trigger_attrs = html_attributes(
          class: "mj-menu-trigger",
          style: :trigger
        )

        label_attrs = html_attributes(
          for: label_key,
          class: "mj-menu-label",
          style: :label,
          align: get_attribute("ico-align")
        )

        ico_open_attrs = html_attributes(
          class: "mj-menu-icon-open",
          style: :icoOpen
        )

        ico_close_attrs = html_attributes(
          class: "mj-menu-icon-close",
          style: :icoClose
        )

        <<~HTML
          #{input_html}
          <div
            #{trigger_attrs}
          >
            <label
              #{label_attrs}
            >
              <span
                #{ico_open_attrs}
              >
                #{get_attribute("ico-open")}
              </span>
              <span
                #{ico_close_attrs}
              >
                #{get_attribute("ico-close")}
              </span>
            </label>
          </div>
        HTML
      end
    end
  end
end
