# frozen_string_literal: true

require "nokogiri"
require_relative "global_data"
require_relative "registry"
require_relative "skeleton"
require_relative "helpers/merge_outlook_conditionals"
require_relative "helpers/minify_outlook_conditionals"

module Emjay
  module Renderer
    # HTML void elements that need self-closing conversion for XML parsing.
    VOID_ELEMENTS_RE = /(<(?:br|hr|img|input|meta|link|area|base|col|embed|param|source|track|wbr)(?:\s[^>]*)?)>/i

    def self.call(mjml_string, options = {})
      # 1. Pre-process and parse MJML string with Nokogiri::XML.
      # Two fixups are needed to bridge MJML (which embeds HTML content) and XML:
      #   a) Convert HTML void elements to self-closing (e.g. <br> → <br/>)
      #      so XML parsing doesn't treat them as unclosed tags
      #   b) Escape bare < characters from template syntax in mj-raw
      #      (e.g. { if item < 5 }) so they don't break XML parsing
      preprocessed = mjml_string.gsub(VOID_ELEMENTS_RE, '\1/>')
      preprocessed = preprocessed.gsub(/<(?![a-zA-Z\/!?])/, RAW_LT_PLACEHOLDER)
      doc = Nokogiri::XML(preprocessed)
      mjml_root = doc.at_xpath("//mjml") || doc.root

      # 2. Build GlobalData
      global_data = GlobalData.new(options)

      # Extract lang/dir from root element
      if mjml_root
        owa = mjml_root["owa"]
        global_data.force_owa_desktop = (owa == "desktop") if owa
        global_data.lang = mjml_root["lang"] || "und"
        global_data.dir = mjml_root["dir"] || "auto"
      end

      # 3. Find mj-head and mj-body
      mj_head_el = mjml_root&.at_xpath("mj-head")
      mj_body_el = mjml_root&.at_xpath("mj-body")

      # Convert Nokogiri elements to our internal data structures (matching JS parsed format)
      components = Registry.components

      # Processing function (matches JS processing)
      apply_attributes = method(:apply_attributes_fn).curry[global_data]

      processing = lambda { |node, ctx|
        return unless node
        node = apply_attributes.call(node) if node.is_a?(Hash)

        component_class = ctx[:components]&.[](node[:tag_name])
        return unless component_class

        component = component_class.new(
          attributes: node[:attributes] || {},
          children: node[:children] || [],
          content: node[:content] || "",
          context: ctx,
          global_attributes: node[:global_attributes] || {},
          raw_attrs: node[:raw_attrs] || {}
        )

        if component.respond_to?(:handler)
          return component.handler
        end

        if component.respond_to?(:render)
          component.render
        end
      }

      # Head helpers context
      head_helpers = {
        components: components,
        global_data: global_data,
        add: ->(attr, *params) { global_data.add(attr, *params) }
      }

      # Process head
      if mj_head_el
        head_node = nokogiri_to_hash(mj_head_el)
        head_result = processing.call(head_node, head_helpers)
        global_data.head_raw = head_result if head_result.is_a?(Array)
      end

      # Body helpers context
      body_helpers = {
        components: components,
        global_data: global_data,
        container_width: "600px",
        add_media_query: ->(class_name, data) {
          global_data.media_queries[class_name] = if data.key?(:padding)
            "{ padding:#{data[:padding]} !important; }"
          else
            pw = data[:parsed_width]
            pw = pw.to_i if pw == pw.to_i
            "{ width:#{pw}#{data[:unit]} !important; max-width: #{pw}#{data[:unit]}; }"
          end
        },
        add_head_style: ->(identifier, head_style_fn) {
          global_data.head_style[identifier] = head_style_fn
        },
        add_component_head_style: ->(head_style_fn) {
          global_data.components_head_style << head_style_fn
        },
        processing: ->(node, ctx) {
          node = apply_attributes.call(node) if node.is_a?(Hash)
          processing.call(node, ctx)
        }
      }

      # Process body
      content = nil
      if mj_body_el
        body_node = nokogiri_to_hash(mj_body_el)
        body_node = apply_attributes.call(body_node)
        content = processing.call(body_node, body_helpers)
      end

      raise "Malformed MJML. Check that your structure is correct and enclosed in <mjml> tags." unless content

      # Minify outlook conditionals
      content = MinifyOutlookConditionals.call(content)

      # Handle mj-raw outside body (before-doctype)
      mjml_root&.xpath("mj-raw")&.each do |raw_el|
        if raw_el["position"] == "file-start"
          global_data.before_doctype += raw_el.inner_html.gsub(RAW_LT_PLACEHOLDER, "<")
        end
      end

      # Apply html_attributes via Nokogiri CSS selectors.
      # Use XML fragment for parsing (preserves table structure, unlike HTML5
      # which foster-parents text out of tables). Protect bare < from template
      # syntax (mj-raw) with placeholders so XML parsing succeeds. Use custom
      # serializer so text nodes (including > in templates) pass through raw.
      unless global_data.html_attributes.empty?
        escaped = content.gsub(/<(?![a-zA-Z\/!?])/, RAW_LT_PLACEHOLDER)
        content_doc = Nokogiri::XML.fragment(escaped)
        global_data.html_attributes.each do |selector, data|
          content_doc.css(selector).each do |node|
            data.each do |attr_name, value|
              node[attr_name] = value || ""
            end
          end
        end
        content = serialize_fragment(content_doc).gsub(RAW_LT_PLACEHOLDER, "<")
      end

      # Wrap in skeleton
      content = Skeleton.call(
        before_doctype: global_data.before_doctype,
        breakpoint: global_data.breakpoint,
        content: content,
        fonts: global_data.fonts,
        media_queries: global_data.media_queries,
        head_style: global_data.head_style,
        components_head_style: global_data.components_head_style,
        head_raw: global_data.head_raw.is_a?(Array) ? global_data.head_raw : [],
        title: global_data.title,
        style: global_data.style,
        force_owa_desktop: global_data.force_owa_desktop,
        printer_support: options[:printer_support] || false,
        inline_style: global_data.inline_style,
        lang: global_data.lang,
        dir: global_data.dir
      )

      # CSS inlining for <mj-style inline="inline">
      if global_data.inline_style.any?
        content = inline_css(content, global_data.inline_style.join("\n"))
      end

      # Merge outlook conditionals
      MergeOutlookConditionals.call(content)
    end

    # Converts a Nokogiri element to a hash matching the JS parsed format
    def self.nokogiri_to_hash(element)
      return nil unless element

      attrs = {}
      element.attributes.each { |name, attr| attrs[name] = attr.value }

      children = element.children.select(&:element?).map { |child| nokogiri_to_hash(child) }

      # For ending-tag components, content is the inner HTML. Only MJML tags
      # can be components — plain HTML (e.g. <a>, <b> nested in mj-text) never
      # is, so don't waste a Registry lookup on it.
      tag_name = element.name
      component_class = tag_name.start_with?("mj-") ? Registry.find(tag_name) : nil
      content = if component_class&.ending_tag?
        inner = element.inner_html.strip
        # Restore escaped bare < characters (from template syntax in mj-raw etc.)
        inner.gsub(RAW_LT_PLACEHOLDER, "<")
      else
        element.children.select(&:text?).map(&:text).join.strip
      end

      {
        tag_name: tag_name,
        attributes: attrs,
        children: children,
        content: content
      }
    end

    # Port of the JS applyAttributes function — merges global defaults, classes, etc.
    def self.apply_attributes_fn(global_data, node, parent_mj_class = "")
      return node unless node.is_a?(Hash)

      attrs = node[:attributes] || {}
      tag_name = node[:tag_name]

      # Resolve mj-class
      classes = (attrs["mj-class"] || "").split(" ")
      attributes_classes = classes.each_with_object({}) do |cls, acc|
        mj_class_values = global_data.classes[cls] || {}
        if acc["css-class"] && mj_class_values["css-class"]
          acc.merge!(mj_class_values)
          acc["css-class"] = "#{acc["css-class"]} #{mj_class_values["css-class"]}"
        else
          acc.merge!(mj_class_values)
        end
      end

      # Default attributes for parent mj-class
      default_attrs_for_classes = parent_mj_class.split(" ").each_with_object({}) do |cls, acc|
        class_defaults = global_data.classes_default.dig(cls, tag_name)
        acc.merge!(class_defaults) if class_defaults
      end

      next_parent_mj_class = attrs["mj-class"] || parent_mj_class

      # Merge: global defaults -> class attrs -> class default attrs -> element attrs (minus mj-class)
      element_attrs = attrs.except("mj-class")
      merged_attrs = (global_data.default_attributes[tag_name] || {})
        .merge(attributes_classes)
        .merge(default_attrs_for_classes)
        .merge(element_attrs)

      # Recurse into children
      merged_children = (node[:children] || []).map { |child|
        apply_attributes_fn(global_data, child, next_parent_mj_class)
      }

      node.merge(
        attributes: merged_attrs,
        raw_attrs: element_attrs,
        global_attributes: global_data.default_attributes["mj-all"] || {},
        children: merged_children
      )
    end

    # Inlines extra CSS rules into element style attributes using premailer.
    # Mirrors the JS behavior: only the extra CSS (from <mj-style inline="inline">)
    # is inlined; existing <style> tags in the document are preserved as-is.
    def self.inline_css(html, extra_css)
      require "premailer"

      premailer = Premailer.new(
        html,
        with_html_string: true,
        css_string: extra_css,
        include_style_tags: false,
        include_link_tags: false,
        preserve_styles: true,
        adapter: :nokogiri
      )
      premailer.to_inline_css
    end

    RAW_LT_PLACEHOLDER = "___MJML_RAW_LT___"
    VOID_ELEMENTS = %w[area base br col embed hr img input link meta param source track wbr].freeze

    # Custom serializer that preserves raw text content (no entity encoding
    # for >, <, etc. in text nodes). Needed because mj-raw injects template
    # syntax like { if item < 5 } that must pass through literally.
    def self.serialize_fragment(node)
      node.children.map { |c| serialize_node(c) }.join
    end

    def self.serialize_node(node)
      if node.text?
        node.text
      elsif node.comment?
        "<!--#{node.content}-->"
      elsif node.element?
        attrs = node.attributes.values.map { |a|
          val = a.value.gsub("&", "&amp;").gsub('"', "&quot;")
          " #{a.name}=\"#{val}\""
        }.join
        if VOID_ELEMENTS.include?(node.name) && node.children.empty?
          "<#{node.name}#{attrs}>"
        else
          "<#{node.name}#{attrs}>#{serialize_fragment(node)}</#{node.name}>"
        end
      else
        node.to_html
      end
    end

    private_class_method :nokogiri_to_hash, :apply_attributes_fn, :inline_css,
      :serialize_fragment, :serialize_node
  end
end
