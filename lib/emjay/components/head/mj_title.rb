# frozen_string_literal: true

require_relative "../../head_component"

module Emjay
  module Components
    class MjTitle < HeadComponent
      def self.component_name
        "mj-title"
      end

      def self.ending_tag?
        true
      end

      def handler
        @context[:add].call(:title, get_content)
      end
    end
  end
end
