# frozen_string_literal: true

require_relative "../../body_component"
require_relative "../../helpers/suffix_css_classes"

module Emjay
  module Components
    class MjCarouselImage < BodyComponent
      def self.component_name
        "mj-carousel-image"
      end

      def self.ending_tag?
        true
      end

      def self.default_attributes
        {
          "alt" => "",
          "target" => "_blank"
        }
      end

      def self.allowed_attributes
        {
          "alt" => "string",
          "href" => "string",
          "rel" => "string",
          "target" => "string",
          "title" => "string",
          "src" => "string",
          "thumbnails-src" => "string",
          "border-radius" => "string",
          "tb-border" => "string",
          "tb-border-radius" => "string"
        }
      end

      def get_styles
        has_thumbnails_supported = thumbnails_supported?
        {
          images: {
            img: {
              "border-radius" => get_attribute("border-radius"),
              "display" => "block",
              "width" => @context[:container_width],
              "max-width" => "100%",
              "height" => "auto"
            },
            firstImageDiv: {},
            otherImageDiv: {
              "display" => "none",
              "mso-hide" => "all"
            }
          },
          radio: {
            input: {
              "display" => "none",
              "mso-hide" => "all"
            }
          },
          thumbnails: {
            a: {
              "border" => get_attribute("tb-border"),
              "border-radius" => get_attribute("tb-border-radius"),
              "display" => has_thumbnails_supported ? "none" : "inline-block",
              "overflow" => "hidden",
              "width" => get_attribute("tb-width")
            },
            img: {
              "display" => "block",
              "width" => "100%",
              "height" => "auto"
            }
          }
        }
      end

      def render
        src = get_attribute("src")
        alt = get_attribute("alt")
        href = get_attribute("href")
        rel = get_attribute("rel")
        title = get_attribute("title")
        index = @props[:index] || 0

        img_attrs = html_attributes(
          title: title,
          src: src,
          alt: alt,
          style: "images.img",
          width: @context[:container_width].to_i,
          border: "0"
        )
        image = "<img\n        #{img_attrs} />"

        css_class = get_attribute("css-class") || ""
        div_style = (index == 0) ? "images.firstImageDiv" : "images.otherImageDiv"
        div_attrs = html_attributes(
          class: "mj-carousel-image mj-carousel-image-#{index + 1} #{css_class}",
          style: div_style
        )

        content = href ? "<a#{html_attributes(href: href, rel: rel, target: "_blank")}>#{image}</a>" : image

        <<~HTML
          <div
            #{div_attrs}
          >
            #{content}
          </div>
        HTML
      end

      def render_radio
        index = @props[:index] || 0
        carousel_id = get_attribute("carouselId")

        input_attrs = html_attributes(
          class: "mj-carousel-radio mj-carousel-#{carousel_id}-radio mj-carousel-#{carousel_id}-radio-#{index + 1}",
          checked: (index == 0) ? "checked" : nil,
          type: "radio",
          name: "mj-carousel-radio-#{carousel_id}",
          id: "mj-carousel-#{carousel_id}-radio-#{index + 1}",
          style: "radio.input"
        )

        <<~HTML
          <input
            #{input_attrs}
          />
        HTML
      end

      def render_thumbnail
        carousel_id = get_attribute("carouselId")
        src = get_attribute("src")
        alt = get_attribute("alt")
        width = get_attribute("tb-width")
        target = get_attribute("target")
        index = @props[:index] || 0
        img_index = index + 1

        css_class = SuffixCssClasses.call(get_attribute("css-class"), "thumbnail")

        a_attrs = html_attributes(
          style: "thumbnails.a",
          href: "##{img_index}",
          target: target,
          class: "mj-carousel-thumbnail mj-carousel-#{carousel_id}-thumbnail mj-carousel-#{carousel_id}-thumbnail-#{img_index} #{css_class}"
        )

        label_attrs = html_attributes(
          for: "mj-carousel-#{carousel_id}-radio-#{img_index}"
        )

        img_attrs = html_attributes(
          style: "thumbnails.img",
          src: get_attribute("thumbnails-src") || src,
          alt: alt,
          width: width.to_i
        )

        <<~HTML
          <a
            #{a_attrs}
          >
            <label#{label_attrs}>
              <img
                #{img_attrs}
              />
            </label>
          </a>
        HTML
      end

      private

      def thumbnails_supported?
        thumbnails = get_attribute("thumbnails") || @context[:thumbnails]
        thumbnails == "supported"
      end
    end
  end
end
