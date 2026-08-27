# frozen_string_literal: true

require_relative "../../body_component"

module Emjay
  module Components
    class MjRaw < BodyComponent
      def self.component_name
        "mj-raw"
      end

      def self.ending_tag?
        true
      end

      def self.raw_element?
        true
      end

      def self.allowed_attributes
        {
          "position" => "enum(file-start)"
        }
      end

      def render
        get_content
      end
    end
  end
end
