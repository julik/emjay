# frozen_string_literal: true

require_relative "../../head_component"

module Emjay
  module Components
    class MjStyle < HeadComponent
      def self.component_name
        "mj-style"
      end

      def self.ending_tag?
        true
      end

      def self.allowed_attributes
        {"inline" => "string"}
      end

      def handler
        add = @context[:add]
        key = if get_attribute("inline") == "inline"
          :inline_style
        else
          :style
        end
        add.call(key, get_content)
      end
    end
  end
end
