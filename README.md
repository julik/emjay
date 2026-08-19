# emjay

A pure-Ruby implementation of [MJML](https://mjml.io), the email markup language. Converts MJML templates to responsive HTML emails — no Node.js, no native extensions, no shelling out.

## Feature parity with MJML

emjay implements the full set of standard MJML components:

**Head components:** `mj-head`, `mj-attributes`, `mj-style` (including `inline`), `mj-font`, `mj-title`, `mj-preview`, `mj-breakpoint`, `mj-html-attributes`

**Body components:** `mj-body`, `mj-section`, `mj-wrapper`, `mj-column`, `mj-group`, `mj-text`, `mj-image`, `mj-button`, `mj-divider`, `mj-spacer`, `mj-table`, `mj-raw`, `mj-hero`, `mj-social` / `mj-social-element`, `mj-navbar` / `mj-navbar-link`, `mj-accordion` / `mj-accordion-element` / `mj-accordion-title` / `mj-accordion-text`, `mj-carousel` / `mj-carousel-image`

**Features:** CSS inlining via `<mj-style inline="inline">`, global default attributes, `mj-class`, `mj-html-attributes` with CSS selectors, custom fonts, responsive breakpoints, Outlook conditionals, `lang`/`dir` attributes.

All components and features from the [MJML documentation](https://documentation.mjml.io/) should work as described. The [MJML templates and examples](https://mjml.io/templates) are a good starting point for building your own emails. Output is tested against the upstream [MJML 5.4.0 JavaScript implementation](https://github.com/mjmlio/mjml/tree/5.4.0) using fixture-based comparison and backported behavioral tests. If you find a case where emjay produces different output from the reference MJML implementation, please [open an issue](https://github.com/julik/emjay/issues).

## Installation

Add to your Gemfile:

```ruby
gem "emjay"
```

Runtime dependencies: `nokogiri` for XML/HTML parsing, `premailer` for CSS inlining (`<mj-style inline="inline">`).

## Usage

### Standalone

```ruby
require "emjay"

mjml = <<~MJML
  <mjml>
    <mj-body>
      <mj-section>
        <mj-column>
          <mj-text>Hello World</mj-text>
        </mj-column>
      </mj-section>
    </mj-body>
  </mjml>
MJML

html = Emjay.to_html(mjml)
```

### Rails

emjay includes a Railtie that registers an ActionView template handler automatically. Create templates with the `.html.mjml` extension:

```
app/views/user_mailer/welcome.html.mjml
```

ERB tags work inside `.mjml` templates — the handler always chains through ERB before compiling MJML:

```erb
<mjml>
  <mj-body>
    <mj-section>
      <mj-column>
        <mj-text>Welcome, <%= @user.name %>!</mj-text>
      </mj-column>
    </mj-section>
  </mj-body>
</mjml>
```

Your mailer needs no special setup:

```ruby
class UserMailer < ApplicationMailer
  def welcome(user)
    @user = user
    mail(to: @user.email)
  end
end
```

Rails resolves the template automatically: `.mjml` selects the handler, `.html` sets the MIME type. If you also provide `welcome.text.erb`, ActionMailer sends a multipart email with both HTML and plain text parts.

### Layouts

MJML layouts work just like regular Rails mailer layouts. Create a layout that wraps `yield` with the MJML boilerplate:

```erb
<%# app/views/layouts/mailer.html.mjml %>
<mjml>
  <mj-head>
    <mj-attributes>
      <mj-all font-family="Helvetica, Arial, sans-serif" />
    </mj-attributes>
  </mj-head>
  <mj-body>
    <%= yield %>
  </mj-body>
</mjml>
```

Then your templates contain only the content sections:

```erb
<%# app/views/user_mailer/welcome.html.mjml %>
<mj-section>
  <mj-column>
    <mj-text>Welcome, <%= @user.name %>!</mj-text>
  </mj-column>
</mj-section>
```

Set the layout in your mailer as usual:

```ruby
class UserMailer < ApplicationMailer
  layout "mailer"
end
```

### Partials

MJML partials work with the standard `render` helper. Use them to share common sections across emails:

```erb
<%# app/views/shared/_header.html.mjml %>
<mj-section background-color="#f0f0f0">
  <mj-column>
    <mj-image src="<%= @logo_url %>" width="150px" />
  </mj-column>
</mj-section>
```

```erb
<%# app/views/user_mailer/welcome.html.mjml %>
<%= render "shared/header" %>
<mj-section>
  <mj-column>
    <mj-text>Welcome!</mj-text>
  </mj-column>
</mj-section>
```

### How it works

The `.mjml` template handler is an ERB passthrough — it does not compile MJML itself. Instead, an ActionMailer interceptor (`Emjay::Rails::MailInterceptor`) compiles the assembled MJML to HTML after Rails has applied layouts and partials. This means `yield` in a layout receives MJML (not HTML), and the full document is compiled in one pass.

## Other Ruby MJML implementations

- [mjml-rails](https://github.com/sighmon/mjml-rails) — Rails integration that shells out to the MJML Node.js binary. Requires Node.js at runtime.
- [mjml-ruby](https://github.com/kolybasov/mjml-ruby) — Ruby wrapper around the MJML Node.js parser. Also requires Node.js.
- [mrml-ruby](https://github.com/jdrouet/mrml/tree/main/packages/mrml-ruby) — Ruby bindings to [MRML](https://github.com/jdrouet/mrml), a Rust reimplementation of MJML. Requires a compiled native extension.

emjay differs from all of the above by being pure Ruby — it has no dependency on Node.js or native extensions.

## License

MIT
