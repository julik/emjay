# frozen_string_literal: true

require "measurometer"

module Emjay
  module Rails
    class MailInterceptor
      MJML_TAG_PATTERN = /<mjml[\s>]/i

      def self.delivering_email(message)
        new.compile_mjml!(message)
      end

      def self.previewing_email(message)
        new.compile_mjml!(message)
      end

      def compile_mjml!(message)
        Measurometer.instrument("emjay.mail_interceptor.compile") { compile_message!(message) }
      end

      private

      def compile_message!(message)
        if message.multipart?
          message.parts.each { |part| compile_part!(part) }
        else
          compile_part!(message)
        end
      end

      def compile_part!(part)
        if part.multipart?
          part.parts.each { |p| compile_part!(p) }
          return
        end

        return unless part.content_type&.include?("text/html") || part.content_type.nil?

        body = part.body.decoded
        return unless MJML_TAG_PATTERN.match?(body)

        part.body = Emjay.to_html(body)
      end
    end
  end
end
