# frozen_string_literal: true

module Emjay
  module Registry
    MAPPING = {
      "mj-attributes" => ["components/head/mj_attributes", :MjAttributes],
      "mj-breakpoint" => ["components/head/mj_breakpoint", :MjBreakpoint],
      "mj-font" => ["components/head/mj_font", :MjFont],
      "mj-head" => ["components/head/mj_head", :MjHead],
      "mj-html-attributes" => ["components/head/mj_html_attributes", :MjHtmlAttributes],
      "mj-preview" => ["components/head/mj_preview", :MjPreview],
      "mj-style" => ["components/head/mj_style", :MjStyle],
      "mj-title" => ["components/head/mj_title", :MjTitle],
      "mj-accordion" => ["components/body/mj_accordion", :MjAccordion],
      "mj-accordion-element" => ["components/body/mj_accordion_element", :MjAccordionElement],
      "mj-accordion-text" => ["components/body/mj_accordion_text", :MjAccordionText],
      "mj-accordion-title" => ["components/body/mj_accordion_title", :MjAccordionTitle],
      "mj-body" => ["components/body/mj_body", :MjBody],
      "mj-button" => ["components/body/mj_button", :MjButton],
      "mj-carousel" => ["components/body/mj_carousel", :MjCarousel],
      "mj-carousel-image" => ["components/body/mj_carousel_image", :MjCarouselImage],
      "mj-column" => ["components/body/mj_column", :MjColumn],
      "mj-divider" => ["components/body/mj_divider", :MjDivider],
      "mj-group" => ["components/body/mj_group", :MjGroup],
      "mj-hero" => ["components/body/mj_hero", :MjHero],
      "mj-image" => ["components/body/mj_image", :MjImage],
      "mj-navbar" => ["components/body/mj_navbar", :MjNavbar],
      "mj-navbar-link" => ["components/body/mj_navbar_link", :MjNavbarLink],
      "mj-raw" => ["components/body/mj_raw", :MjRaw],
      "mj-section" => ["components/body/mj_section", :MjSection],
      "mj-social" => ["components/body/mj_social", :MjSocial],
      "mj-social-element" => ["components/body/mj_social_element", :MjSocialElement],
      "mj-spacer" => ["components/body/mj_spacer", :MjSpacer],
      "mj-table" => ["components/body/mj_table", :MjTable],
      "mj-text" => ["components/body/mj_text", :MjText],
      "mj-wrapper" => ["components/body/mj_wrapper", :MjWrapper]
    }.freeze

    @loaded = {}
    @mutex = Mutex.new

    def self.register(component_class)
      @loaded[component_class.component_name] = component_class
    end

    def self.find(tag_name)
      return @loaded[tag_name] if @loaded.key?(tag_name)

      entry = MAPPING[tag_name]
      return nil unless entry

      @mutex.synchronize do
        return @loaded[tag_name] if @loaded.key?(tag_name)

        require_relative entry[0]
        @loaded[tag_name] = Emjay::Components.const_get(entry[1])
      end
    end

    # Lazy hash-like proxy: the renderer only ever does `components[tag]`,
    # so we resolve on lookup instead of eager-loading every component.
    class LazyComponents
      def [](tag_name)
        Registry.find(tag_name)
      end

      include Enumerable

      def each
        MAPPING.each_key { |tag| yield(tag, Registry.find(tag)) }
      end

      def keys
        MAPPING.keys
      end

      def values
        MAPPING.each_key.map { |tag| Registry.find(tag) }
      end
    end

    COMPONENTS = LazyComponents.new

    def self.components
      COMPONENTS
    end
  end
end
