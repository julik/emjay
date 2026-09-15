# frozen_string_literal: true

require "measurometer"
require_relative "helpers/fonts"
require_relative "helpers/media_queries"
require_relative "helpers/styles"

module Emjay
  module Skeleton
    # Builds the full HTML document skeleton. Port of skeleton.js.
    def self.call(options)
      before_doctype = options[:before_doctype] || ""
      breakpoint = options[:breakpoint] || "480px"
      content = options[:content] || ""
      fonts = options[:fonts] || {}
      media_queries = options[:media_queries] || {}
      head_style = options[:head_style] || {}
      components_head_style = options[:components_head_style] || []
      head_raw = options[:head_raw] || []
      title = options[:title] || ""
      style = options[:style] || []
      force_owa_desktop = options[:force_owa_desktop] || false
      printer_support = options[:printer_support] || false
      inline_style = options[:inline_style] || []
      lang = options[:lang] || "und"
      dir = options[:dir] || "auto"

      before_doctype_str = before_doctype.empty? ? "" : "#{before_doctype}\n"

      fonts_tags = Measurometer.instrument("emjay.skeleton.fonts") do
        Fonts.build_tags(content, inline_style, fonts)
      end
      media_query_tags = Measurometer.instrument("emjay.skeleton.media_queries") do
        MediaQueries.build_tags(breakpoint, media_queries,
          force_owa_desktop: force_owa_desktop,
          printer_support: printer_support)
      end
      component_styles = Measurometer.instrument("emjay.skeleton.component_styles") do
        Styles.build_from_components(breakpoint, components_head_style, head_style)
      end
      tag_styles = Measurometer.instrument("emjay.skeleton.tag_styles") do
        Styles.build_from_tags(breakpoint, style)
      end
      raw = head_raw.compact.join("\n")

      <<~HTML
        #{before_doctype_str}<!doctype html>
        <html lang="#{lang}" dir="#{dir}" xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office">
          <head>
            <title>#{title}</title>
            <!--[if !mso]><!-->
            <meta http-equiv="X-UA-Compatible" content="IE=edge">
            <!--<![endif]-->
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <style type="text/css">
              #outlook a { padding:0; }
              body { margin:0;padding:0;-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%; }
              table, td { border-collapse:collapse;mso-table-lspace:0pt;mso-table-rspace:0pt; }
              img { border:0;height:auto;line-height:100%; outline:none;text-decoration:none;-ms-interpolation-mode:bicubic; }
              p { display:block;margin:13px 0; }
            </style>
            <!--[if mso]>
            <noscript>
            <xml>
            <o:OfficeDocumentSettings>
              <o:AllowPNG/>
              <o:PixelsPerInch>96</o:PixelsPerInch>
            </o:OfficeDocumentSettings>
            </xml>
            </noscript>
            <![endif]-->
            <!--[if lte mso 11]>
            <style type="text/css">
              .mj-outlook-group-fix { width:100% !important; }
            </style>
            <![endif]-->
            #{fonts_tags}
            #{media_query_tags}
            #{component_styles}
            #{tag_styles}
            #{raw}
          </head>
          #{content}
        </html>
      HTML
    end
  end
end
