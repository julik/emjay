# frozen_string_literal: true

require_relative "../../head_component"

module Emjay
  module Components
    class MjBreakpoint < HeadComponent
      def self.component_name
        "mj-breakpoint"
      end

      def self.ending_tag?
        true
      end

      def self.allowed_attributes
        {"width" => "unit(px)"}
      end

      def handler
        @context[:add].call(:breakpoint, get_attribute("width"))
      end
    end
  end
end
