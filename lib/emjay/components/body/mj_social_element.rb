# frozen_string_literal: true

require_relative "../../body_component"
require_relative "../../registry"

module Emjay
  module Components
    class MjSocialElement < BodyComponent
      IMG_BASE_URL = "https://www.mailjet.com/images/theme/v1/icons/ico-social/"

      DEFAULT_SOCIAL_NETWORKS = {
        "facebook" => {"share-url" => "https://www.facebook.com/sharer/sharer.php?u=[[URL]]", "background-color" => "#3b5998", "src" => "#{IMG_BASE_URL}facebook.png"},
        "twitter" => {"share-url" => "https://twitter.com/intent/tweet?url=[[URL]]", "background-color" => "#55acee", "src" => "#{IMG_BASE_URL}twitter.png"},
        "x" => {"share-url" => "https://twitter.com/intent/tweet?url=[[URL]]", "background-color" => "#000000", "src" => "#{IMG_BASE_URL}twitter-x.png"},
        "google" => {"share-url" => "https://plus.google.com/share?url=[[URL]]", "background-color" => "#dc4e41", "src" => "#{IMG_BASE_URL}google-plus.png"},
        "pinterest" => {"share-url" => "https://pinterest.com/pin/create/button/?url=[[URL]]&media=&description=", "background-color" => "#bd081c", "src" => "#{IMG_BASE_URL}pinterest.png"},
        "linkedin" => {"share-url" => "https://www.linkedin.com/shareArticle?mini=true&url=[[URL]]&title=&summary=&source=", "background-color" => "#0077b5", "src" => "#{IMG_BASE_URL}linkedin.png"},
        "instagram" => {"background-color" => "#3f729b", "src" => "#{IMG_BASE_URL}instagram.png"},
        "web" => {"src" => "#{IMG_BASE_URL}web.png", "background-color" => "#4BADE9"},
        "snapchat" => {"src" => "#{IMG_BASE_URL}snapchat.png", "background-color" => "#FFFA54"},
        "youtube" => {"src" => "#{IMG_BASE_URL}youtube.png", "background-color" => "#EB3323"},
        "tumblr" => {"src" => "#{IMG_BASE_URL}tumblr.png", "share-url" => "https://www.tumblr.com/widgets/share/tool?canonicalUrl=[[URL]]", "background-color" => "#344356"},
        "github" => {"src" => "#{IMG_BASE_URL}github.png", "background-color" => "#000000"},
        "xing" => {"src" => "#{IMG_BASE_URL}xing.png", "share-url" => "https://www.xing.com/app/user?op=share&url=[[URL]]", "background-color" => "#296366"},
        "vimeo" => {"src" => "#{IMG_BASE_URL}vimeo.png", "background-color" => "#53B4E7"},
        "medium" => {"src" => "#{IMG_BASE_URL}medium.png", "background-color" => "#000000"},
        "soundcloud" => {"src" => "#{IMG_BASE_URL}soundcloud.png", "background-color" => "#EF7F31"},
        "dribbble" => {"src" => "#{IMG_BASE_URL}dribbble.png", "background-color" => "#D95988"}
      }.freeze

      # Build noshare variants
      SOCIAL_NETWORKS = DEFAULT_SOCIAL_NETWORKS.each_with_object({}) { |(key, val), hash|
        hash[key] = val
        hash["#{key}-noshare"] = val.merge("share-url" => "[[URL]]")
      }.freeze

      def self.component_name
        "mj-social-element"
      end

      def self.ending_tag?
        true
      end

      def self.default_attributes
        {
          "alt" => "",
          "align" => "left",
          "icon-position" => "left",
          "color" => "#000",
          "border-radius" => "3px",
          "font-family" => "Ubuntu, Helvetica, Arial, sans-serif",
          "font-size" => "13px",
          "line-height" => "1",
          "padding" => "4px",
          "text-padding" => "4px 4px 4px 0",
          "target" => "_blank",
          "text-decoration" => "none",
          "vertical-align" => "middle"
        }
      end

      def self.allowed_attributes
        {
          "align" => "enum(left,center,right)",
          "icon-position" => "enum(left,right)",
          "background-color" => "color",
          "color" => "color",
          "border-radius" => "string",
          "font-family" => "string",
          "font-size" => "unit(px)",
          "font-style" => "string",
          "font-weight" => "string",
          "href" => "string",
          "icon-size" => "unit(px,%)",
          "icon-height" => "unit(px,%)",
          "icon-padding" => "unit(px,%){1,4}",
          "line-height" => "unit(px,%,)",
          "name" => "string",
          "padding-bottom" => "unit(px,%)",
          "padding-left" => "unit(px,%)",
          "padding-right" => "unit(px,%)",
          "padding-top" => "unit(px,%)",
          "padding" => "unit(px,%){1,4}",
          "text-padding" => "unit(px,%){1,4}",
          "rel" => "string",
          "src" => "string",
          "srcset" => "string",
          "sizes" => "string",
          "alt" => "string",
          "title" => "string",
          "target" => "string",
          "text-decoration" => "string",
          "vertical-align" => "enum(top,middle,bottom)"
        }
      end

      def get_styles
        social = get_social_attributes
        icon_size = social["icon-size"]
        icon_height = social["icon-height"]
        bg_color = social["background-color"]

        {
          td: {
            "padding" => get_attribute("padding"),
            "padding-top" => get_attribute("padding-top"),
            "padding-right" => get_attribute("padding-right"),
            "padding-bottom" => get_attribute("padding-bottom"),
            "padding-left" => get_attribute("padding-left"),
            "vertical-align" => get_attribute("vertical-align")
          },
          table: {
            "background" => bg_color,
            "border-radius" => get_attribute("border-radius"),
            "width" => icon_size
          },
          icon: {
            "padding" => get_attribute("icon-padding"),
            "font-size" => "0",
            "height" => icon_height || icon_size,
            "vertical-align" => "middle",
            "width" => icon_size
          },
          img: {
            "border" => "0",
            "border-radius" => get_attribute("border-radius"),
            "display" => "block"
          },
          tdText: {
            "vertical-align" => "middle",
            "padding" => get_attribute("text-padding"),
            "text-align" => get_attribute("align")
          },
          text: {
            "color" => get_attribute("color"),
            "font-size" => get_attribute("font-size"),
            "font-weight" => get_attribute("font-weight"),
            "font-style" => get_attribute("font-style"),
            "font-family" => get_attribute("font-family"),
            "line-height" => get_attribute("line-height"),
            "text-decoration" => get_attribute("text-decoration")
          }
        }
      end

      def render
        social = get_social_attributes
        src = social["src"]
        srcset = social["srcset"]
        sizes = social["sizes"]
        href = social["href"]
        icon_size = social["icon-size"]

        has_link = !!get_attribute("href")
        icon_position = get_attribute("icon-position")

        icon_html = render_icon(src, srcset, sizes, href, icon_size, has_link)
        content_html = render_text_content(href, has_link)

        tr_attrs = html_attributes(class: get_attribute("css-class"))

        parts = if icon_position == "left"
          "#{icon_html} #{content_html}"
        else
          "#{content_html} #{icon_html}"
        end

        <<~HTML
          <tr
            #{tr_attrs}
          >
            #{parts}
          </tr>
        HTML
      end

      private

      def get_social_attributes
        network = SOCIAL_NETWORKS[get_attribute("name")] || {}
        href = get_attribute("href")

        if href && network["share-url"]
          href = network["share-url"].gsub("[[URL]]", href)
        end

        attrs = %w[icon-size icon-height srcset sizes src background-color].each_with_object({}) do |attr, result|
          result[attr] = get_attribute(attr) || network[attr]
        end

        attrs.merge("href" => href)
      end

      def render_icon(src, srcset, sizes, href, icon_size, has_link)
        td_attrs = html_attributes(style: :td)
        table_attrs = html_attributes(
          border: "0",
          cellpadding: "0",
          cellspacing: "0",
          role: "presentation",
          style: :table
        )
        icon_td_attrs = html_attributes(style: :icon)

        a_open = has_link ? "<a#{html_attributes(href: href, rel: get_attribute("rel"), target: get_attribute("target"))}>" : ""
        a_close = has_link ? "</a>" : ""

        img_attrs = html_attributes(
          alt: get_attribute("alt"),
          title: get_attribute("title"),
          src: src,
          style: :img,
          width: icon_size.to_i,
          sizes: sizes,
          srcset: srcset
        )

        <<~HTML
          <td#{td_attrs}>
            <table
              #{table_attrs}
            >
              <tbody>
                <tr>
                  <td#{icon_td_attrs}>
                    #{a_open}
                      <img
                        #{img_attrs}
                      />
                    #{a_close}
                  </td>
                </tr>
              </tbody>
            </table>
          </td>
        HTML
      end

      def render_text_content(href, has_link)
        content = get_content
        return "" if content.nil? || content.empty?

        td_text_attrs = html_attributes(style: :tdText)

        if has_link
          a_attrs = html_attributes(
            href: href,
            style: :text,
            rel: get_attribute("rel"),
            target: get_attribute("target")
          )
          <<~HTML
            <td#{td_text_attrs}>
              <a#{a_attrs}>
                #{content}
              </a>
            </td>
          HTML
        else
          span_attrs = html_attributes(style: :text)
          <<~HTML
            <td#{td_text_attrs}>
              <span#{span_attrs}>#{content}</span>
            </td>
          HTML
        end
      end
    end
  end

  Registry.register(Components::MjSocialElement)
end
