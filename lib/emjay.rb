# frozen_string_literal: true

require_relative "emjay/version"
require_relative "emjay/registry"
require_relative "emjay/component"
require_relative "emjay/body_component"
require_relative "emjay/head_component"
require_relative "emjay/global_data"
require_relative "emjay/renderer"
require_relative "emjay/skeleton"

# Helpers
require_relative "emjay/helpers/shorthand_parser"
require_relative "emjay/helpers/width_parser"
require_relative "emjay/helpers/conditional_tag"
require_relative "emjay/helpers/suffix_css_classes"
require_relative "emjay/helpers/merge_outlook_conditionals"
require_relative "emjay/helpers/minify_outlook_conditionals"
require_relative "emjay/helpers/fonts"
require_relative "emjay/helpers/media_queries"
require_relative "emjay/helpers/styles"
require_relative "emjay/helpers/make_lower_breakpoint"
require_relative "emjay/helpers/gen_random_hex_string"

# Components are autoloaded on demand via Emjay::Registry — see registry.rb.

module Emjay
  def self.to_html(mjml_string, options = {})
    Renderer.call(mjml_string, options)
  end
end

require "emjay/railtie" if defined?(Rails::Railtie)
