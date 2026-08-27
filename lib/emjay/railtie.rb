# frozen_string_literal: true

module Emjay
  class Railtie < Rails::Railtie
    # Register the template handler on :action_view load, not :action_mailer.
    # ActionView's FileSystemResolver builds its PathParser regex from the
    # registered extensions on first template lookup; if ActionView loads
    # before ActionMailer (e.g. a controller renders a view first), the
    # regex is cached without :mjml and .html.mjml templates stay invisible
    # for the rest of the process.
    initializer "emjay.register_template_handler" do
      ActiveSupport.on_load(:action_view) do
        require "emjay/rails/template_handler"
        ActionView::Template.register_template_handler(:mjml, Emjay::Rails::TemplateHandler)
      end
    end

    initializer "emjay.register_mail_interceptor" do
      ActiveSupport.on_load(:action_mailer) do
        require "emjay/rails/mail_interceptor"
        interceptor = Emjay::Rails::MailInterceptor
        ActionMailer::Base.register_interceptor(interceptor)
        ActionMailer::Base.register_preview_interceptor(interceptor)
      end
    end
  end
end
