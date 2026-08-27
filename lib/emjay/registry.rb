# frozen_string_literal: true

module Emjay
  # Lazy autoloader for MJML components. Scans `lib/emjay/components/**/*.rb`
  # once at load time, then derives both the MJML tag name and the Ruby class
  # from each filename:
  #
  #   components/body/mj_button.rb  →  tag "mj-button"  →  Emjay::Components::MjButton
  #
  # Files are `require`d and constants resolved on first `find`.
  module Registry
    COMPONENTS_ROOT = File.expand_path("components", __dir__)

    PATHS = Dir.glob("{head,body}/*.rb", base: COMPONENTS_ROOT).sort.each_with_object({}) do |rel, h|
      basename = File.basename(rel, ".rb") # e.g. "mj_html_attributes"
      tag = basename.tr("_", "-")           # → "mj-html-attributes"
      h[tag] = File.join(COMPONENTS_ROOT, rel)
    end.freeze

    @loaded = {}
    @mutex = Mutex.new

    def self.find(tag_name)
      @loaded[tag_name] ||= load_component(tag_name)
    end

    def self.components
      @components ||= LazyComponents.new
    end

    # Kept for backwards compatibility with callers that eagerly register.
    def self.register(component_class)
      @loaded[component_class.component_name] = component_class
    end

    def self.load_component(tag_name)
      path = PATHS[tag_name] or return nil
      @mutex.synchronize do
        return @loaded[tag_name] if @loaded[tag_name]
        require path
        const_name = File.basename(path, ".rb").split("_").map(&:capitalize).join
        Emjay::Components.const_get(const_name)
      end
    end

    # The renderer treats `Registry.components` as a hash keyed by tag name.
    # This proxy resolves each lookup through `Registry.find` so components
    # only load when actually referenced.
    class LazyComponents
      include Enumerable

      def [](tag_name)
        Registry.find(tag_name)
      end

      def each
        PATHS.each_key { |tag| yield tag, Registry.find(tag) }
      end

      def keys
        PATHS.keys
      end

      def values
        PATHS.each_key.map { |tag| Registry.find(tag) }
      end
    end
  end
end
