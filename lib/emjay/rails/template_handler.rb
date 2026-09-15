# frozen_string_literal: true

require "measurometer"

module Emjay
  module Rails
    module TemplateHandler
      def self.call(template, source)
        # Pure ERB passthrough — exists only to register .mjml as a valid
        # template extension with ERB support. MJML → HTML compilation
        # happens later via Emjay::Rails::MailInterceptor, after Rails
        # has assembled the full render (template + layout).
        Measurometer.instrument("emjay.template_handler.compile") do
          erb_handler = ActionView::Template.registered_template_handler(:erb)
          erb_handler.call(template, source)
        end
      end
    end
  end
end
