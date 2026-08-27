# frozen_string_literal: true

require_relative "../../body_component"
require_relative "../../helpers/conditional_tag"
require_relative "../../helpers/gen_random_hex_string"

module Emjay
  module Components
    class MjCarousel < BodyComponent
      def self.component_name
        "mj-carousel"
      end

      def self.default_attributes
        {
          "align" => "center",
          "border-radius" => "6px",
          "icon-width" => "44px",
          "left-icon" => "https://i.imgur.com/xTh3hln.png",
          "right-icon" => "https://i.imgur.com/os7o9kz.png",
          "thumbnails" => "visible",
          "tb-border" => "2px solid transparent",
          "tb-border-radius" => "6px",
          "tb-hover-border-color" => "#fead0d",
          "tb-selected-border-color" => "#cccccc"
        }
      end

      def self.allowed_attributes
        {
          "align" => "enum(left,center,right)",
          "border-radius" => "string",
          "container-background-color" => "color",
          "icon-width" => "unit(px,%)",
          "left-icon" => "string",
          "padding" => "unit(px,%){1,4}",
          "padding-top" => "unit(px,%)",
          "padding-bottom" => "unit(px,%)",
          "padding-left" => "unit(px,%)",
          "padding-right" => "unit(px,%)",
          "right-icon" => "string",
          "thumbnails" => "enum(visible,hidden,supported)",
          "tb-border" => "string",
          "tb-border-radius" => "string",
          "tb-hover-border-color" => "color",
          "tb-selected-border-color" => "color",
          "tb-width" => "unit(px,%)"
        }
      end

      def initialize(initial_data = {})
        super
        @carousel_id = GenRandomHexString.call(16)
      end

      def component_head_style(_breakpoint = nil)
        children = @props[:children] || []
        length = children.length
        return "" if length == 0

        carousel_css = build_carousel_css(length)
        fallback = build_fallback_css(length)

        "\n#{carousel_css}\n#{fallback}"
      end

      def get_styles
        {
          carousel: {
            div: {
              "display" => "table",
              "width" => "100%",
              "table-layout" => "fixed",
              "text-align" => "center",
              "font-size" => "0px"
            },
            table: {
              "caption-side" => "top",
              "display" => "table-caption",
              "table-layout" => "fixed",
              "width" => "100%"
            }
          },
          images: {
            td: {
              "padding" => "0px"
            }
          },
          controls: {
            div: {
              "display" => "none",
              "mso-hide" => "all"
            },
            img: {
              "display" => "block",
              "width" => get_attribute("icon-width"),
              "height" => "auto"
            },
            td: {
              "font-size" => "0px",
              "display" => "none",
              "mso-hide" => "all",
              "padding" => "0px"
            }
          }
        }
      end

      def get_child_context
        @context.merge(thumbnails: get_attribute("thumbnails"))
      end

      def render
        children = @props[:children] || []

        carousel_html = ConditionalTag.mso_conditional_tag(
          render_carousel_content(children),
          negation: true
        )

        fallback_html = render_fallback(children)

        <<~HTML
          #{carousel_html}
          #{fallback_html}
        HTML
      end

      private

      def thumbnails_width
        children = @props[:children] || []
        return 0 if children.empty?

        get_attribute("tb-width") ||
          "#{[@context[:container_width].to_f / children.length, 110].min.to_i}px"
      end

      def render_carousel_content(children)
        div_attrs = html_attributes(class: "mj-carousel")
        content_attrs = html_attributes(
          class: "mj-carousel-content mj-carousel-#{@carousel_id}-content",
          style: "carousel.div"
        )

        <<~HTML
          <div
            #{div_attrs}
          >
            #{generate_radios(children)}
            <div
              #{content_attrs}
            >
              #{generate_thumbnails(children)}
              #{generate_carousel(children)}
            </div>
          </div>
        HTML
      end

      def generate_radios(children)
        render_children(children,
          renderer: ->(component) { component.render_radio },
          attributes: {"carouselId" => @carousel_id})
      end

      def generate_thumbnails(children)
        return "" unless %w[visible supported].include?(get_attribute("thumbnails"))

        render_children(children,
          attributes: {
            "tb-border" => get_attribute("tb-border"),
            "tb-border-radius" => get_attribute("tb-border-radius"),
            "tb-width" => thumbnails_width,
            "carouselId" => @carousel_id
          },
          renderer: ->(component) { component.render_thumbnail })
      end

      def generate_controls(children, direction, icon)
        icon_width = get_attribute("icon-width").to_i
        td_attrs = html_attributes(
          class: "mj-carousel-#{@carousel_id}-icons-cell",
          style: "controls.td"
        )
        div_attrs = html_attributes(
          class: "mj-carousel-#{direction}-icons",
          style: "controls.div"
        )

        labels = (1..children.length).map do |i|
          label_attrs = html_attributes(
            for: "mj-carousel-#{@carousel_id}-radio-#{i}",
            class: "mj-carousel-#{direction} mj-carousel-#{direction}-#{i}"
          )
          img_attrs = html_attributes(
            src: icon,
            alt: direction,
            style: "controls.img",
            width: icon_width
          )
          <<~LABEL
            <label
              #{label_attrs}
            >
              <img
                #{img_attrs}
              />
            </label>
          LABEL
        end.join

        <<~HTML
          <td
            #{td_attrs}
          >
            <div
              #{div_attrs}
            >
              #{labels}
            </div>
          </td>
        HTML
      end

      def generate_images(children)
        td_attrs = html_attributes(style: "images.td")
        div_attrs = html_attributes(class: "mj-carousel-images")

        images_html = render_children(children,
          attributes: {"border-radius" => get_attribute("border-radius")})

        <<~HTML
          <td
            #{td_attrs}
          >
            <div
              #{div_attrs}
            >
              #{images_html}
            </div>
          </td>
        HTML
      end

      def generate_carousel(children)
        table_attrs = html_attributes(
          style: "carousel.table",
          border: "0",
          cellpadding: "0",
          cellspacing: "0",
          width: "100%",
          role: "presentation",
          class: "mj-carousel-main"
        )

        <<~HTML
          <table
            #{table_attrs}
          >
            <tbody>
              <tr>
                #{generate_controls(children, "previous", get_attribute("left-icon"))}
                #{generate_images(children)}
                #{generate_controls(children, "next", get_attribute("right-icon"))}
              </tr>
            </tbody>
          </table>
        HTML
      end

      def render_fallback(children)
        return "" if children.empty?

        ConditionalTag.mso_conditional_tag(
          render_children([children[0]],
            attributes: {"border-radius" => get_attribute("border-radius")})
        )
      end

      def build_carousel_css(length)
        id = @carousel_id

        hide_all = (0...length).map { |i|
          ".mj-carousel-#{id}-radio:checked #{"+ * " * i}+ .mj-carousel-content .mj-carousel-image"
        }.join(",")

        show_selected = (0...length).map { |i|
          ".mj-carousel-#{id}-radio-#{i + 1}:checked #{"+ * " * (length - i - 1)}+ .mj-carousel-content .mj-carousel-image-#{i + 1}"
        }.join(",")

        next_icons = (0...length).map { |i|
          ".mj-carousel-#{id}-radio-#{i + 1}:checked #{"+ * " * (length - i - 1)}+ .mj-carousel-content .mj-carousel-next-#{((i + (1 % length) + length) % length) + 1}"
        }.join(",")

        prev_icons = (0...length).map { |i|
          ".mj-carousel-#{id}-radio-#{i + 1}:checked #{"+ * " * (length - i - 1)}+ .mj-carousel-content .mj-carousel-previous-#{((i - (1 % length) + length) % length) + 1}"
        }.join(",")

        selected_thumbnail = (0...length).map { |i|
          ".mj-carousel-#{id}-radio-#{i + 1}:checked #{"+ * " * (length - i - 1)}+ .mj-carousel-content .mj-carousel-#{id}-thumbnail-#{i + 1}"
        }.join(",")

        show_thumbnails = (0...length).map { |i|
          ".mj-carousel-#{id}-radio-#{i + 1}:checked #{"+ * " * (length - i - 1)}+ .mj-carousel-content .mj-carousel-#{id}-thumbnail\n          "
        }.join(",")

        hide_on_hover = (0...length).map { |i|
          ".mj-carousel-#{id}-thumbnail:hover #{"+ * " * (length - i - 1)}+ .mj-carousel-main .mj-carousel-image"
        }.join(",")

        show_on_hover = (0...length).map { |i|
          ".mj-carousel-#{id}-thumbnail-#{i + 1}:hover #{"+ * " * (length - i - 1)}+ .mj-carousel-main .mj-carousel-image-#{i + 1}"
        }.join(",")

        <<~CSS
          .mj-carousel {
            -webkit-user-select: none;
            -moz-user-select: none;
            user-select: none;
          }

          .mj-carousel-#{id}-icons-cell {
            display: table-cell !important;
            width: #{get_attribute("icon-width")} !important;
          }

          .mj-carousel-radio,
          .mj-carousel-next,
          .mj-carousel-previous {
            display: none !important;
          }

          .mj-carousel-thumbnail,
          .mj-carousel-next,
          .mj-carousel-previous {
            touch-action: manipulation;
          }

          #{hide_all} {
            display: none !important;
          }

          #{show_selected} {
            display: block !important;
          }

          .mj-carousel-previous-icons,
          .mj-carousel-next-icons,
          #{next_icons},
          #{prev_icons} {
            display: block !important;
          }

          #{selected_thumbnail} {
            border-color: #{get_attribute("tb-selected-border-color")} !important;
          }

          #{show_thumbnails} {
            display: inline-block !important;
          }

          .mj-carousel-image img + div,
          .mj-carousel-thumbnail img + div {
            display: none !important;
          }

          #{hide_on_hover} {
            display: none !important;
          }

          .mj-carousel-thumbnail:hover {
            border-color: #{get_attribute("tb-hover-border-color")} !important;
          }

          #{show_on_hover} {
            display: block !important;
          }
        CSS
      end

      def build_fallback_css(length)
        id = @carousel_id
        <<~CSS
          .mj-carousel noinput { display:block !important; }
          .mj-carousel noinput .mj-carousel-image-1 { display: block !important;  }
          .mj-carousel noinput .mj-carousel-arrows,
          .mj-carousel noinput .mj-carousel-thumbnails { display: none !important; }

          [owa] .mj-carousel-thumbnail { display: none !important; }

          @media screen yahoo {
              .mj-carousel-#{id}-icons-cell,
              .mj-carousel-previous-icons,
              .mj-carousel-next-icons {
                  display: none !important;
              }

              .mj-carousel-#{id}-radio-1:checked #{"+ *" * (length - 1)}+ .mj-carousel-content .mj-carousel-#{id}-thumbnail-1 {
                  border-color: transparent;
              }
          }
        CSS
      end
    end
  end
end
