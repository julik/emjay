# frozen_string_literal: true

require_relative "../../body_component"
require_relative "../../helpers/conditional_tag"
require_relative "../../helpers/suffix_css_classes"

module Emjay
  module Components
    class MjNavbarLink < BodyComponent
      def self.component_name
        "mj-navbar-link"
      end

      def self.ending_tag?
        true
      end

      def self.default_attributes
        {
          "color" => "#000000",
          "font-family" => "Ubuntu, Helvetica, Arial, sans-serif",
          "font-size" => "13px",
          "font-weight" => "normal",
          "line-height" => "22px",
          "padding" => "15px 10px",
          "target" => "_blank",
          "text-decoration" => "none",
          "text-transform" => "uppercase"
        }
      end

      def self.allowed_attributes
        {
          "color" => "color",
          "font-family" => "string",
          "font-size" => "unit(px)",
          "font-style" => "string",
          "font-weight" => "string",
          "href" => "string",
          "name" => "string",
          "target" => "string",
          "rel" => "string",
          "letter-spacing" => "unitWithNegative(px,em)",
          "line-height" => "unit(px,%,)",
          "padding-bottom" => "unit(px,%)",
          "padding-left" => "unit(px,%)",
          "padding-right" => "unit(px,%)",
          "padding-top" => "unit(px,%)",
          "padding" => "unit(px,%){1,4}",
          "text-decoration" => "string",
          "text-transform" => "string"
        }
      end

      def get_styles
        {
          a: {
            "display" => "inline-block",
            "color" => get_attribute("color"),
            "font-family" => get_attribute("font-family"),
            "font-size" => get_attribute("font-size"),
            "font-style" => get_attribute("font-style"),
            "font-weight" => get_attribute("font-weight"),
            "letter-spacing" => get_attribute("letter-spacing"),
            "line-height" => get_attribute("line-height"),
            "text-decoration" => get_attribute("text-decoration"),
            "text-transform" => get_attribute("text-transform"),
            "padding" => get_attribute("padding"),
            "padding-top" => get_attribute("padding-top"),
            "padding-left" => get_attribute("padding-left"),
            "padding-right" => get_attribute("padding-right"),
            "padding-bottom" => get_attribute("padding-bottom")
          },
          td: {
            "padding" => get_attribute("padding"),
            "padding-top" => get_attribute("padding-top"),
            "padding-left" => get_attribute("padding-left"),
            "padding-right" => get_attribute("padding-right"),
            "padding-bottom" => get_attribute("padding-bottom")
          }
        }
      end

      def render
        td_attrs = html_attributes(
          style: :td,
          class: SuffixCssClasses.call(get_attribute("css-class"), "outlook")
        )

        <<~HTML
          #{ConditionalTag.conditional_tag("<td#{td_attrs}>")}
            #{render_content}
            #{ConditionalTag.conditional_tag("</td>")}
        HTML
      end

      private

      def render_content
        href = get_attribute("href")
        navbar_base_url = get_attribute("navbarBaseUrl")
        link = navbar_base_url ? "#{navbar_base_url}#{href}" : href

        css_class = get_attribute("css-class")
        css_suffix = css_class ? " #{css_class}" : ""

        a_attrs = html_attributes(
          class: "mj-link#{css_suffix}",
          href: link,
          rel: get_attribute("rel"),
          target: get_attribute("target"),
          name: get_attribute("name"),
          style: :a
        )

        <<~HTML
          <a
            #{a_attrs}
          >
            #{get_content}
          </a>
        HTML
      end
    end
  end
end
