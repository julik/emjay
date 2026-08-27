# frozen_string_literal: true

require_relative "../../head_component"

module Emjay
  module Components
    class MjAttributes < HeadComponent
      def self.component_name
        "mj-attributes"
      end

      def handler
        add = @context[:add]
        children = @props[:children] || []

        children.each do |child|
          tag_name = child[:tag_name]
          attributes = child[:attributes] || {}
          child_children = child[:children] || []

          if tag_name == "mj-class"
            name = attributes["name"]
            add.call(:classes, name, attributes.except("name"))
            add.call(:classes_default, name,
              child_children.each_with_object({}) { |cc, acc|
                acc[cc[:tag_name]] = cc[:attributes] || {}
              })
          else
            add.call(:default_attributes, tag_name, attributes)
          end
        end
      end
    end
  end
end
