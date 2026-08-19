# frozen_string_literal: true

require_relative "../test_helper"

class ComparisonHelpersTest < Minitest::Test
  def test_normalize_html_strips_leading_whitespace
    assert_equal "<div>\n<p>\nhi</p>\n</div>",
      normalize_html("  <div>\n    <p>hi</p>\n  </div>")
  end

  def test_normalize_html_strips_trailing_whitespace
    assert_equal "<div>",
      normalize_html("<div>   ")
  end

  def test_normalize_html_collapses_blank_lines
    assert_equal "<div>\n</div>",
      normalize_html("<div>\n\n\n</div>")
  end

  def test_normalize_html_handles_crlf
    assert_equal "<div>\n</div>",
      normalize_html("<div>\r\n</div>")
  end

  def test_normalize_html_collapses_multiline_tags
    # JS template literal style — attributes on separate lines
    js_style = "<div\n   class=\"foo\"\n   style=\"color:red;\"\n>"
    assert_equal '<div class="foo" style="color:red;">', normalize_html(js_style)
  end

  def test_normalize_html_collapses_double_spaces_in_tags
    # JS sometimes produces <body  style="..."> (double space)
    assert_equal '<body style="word-spacing:normal;">',
      normalize_html('<body  style="word-spacing:normal;">')
  end

  def test_normalize_html_strips_trailing_space_before_close
    # JS produces width="600" > (space before >)
    assert_equal '<table width="600">',
      normalize_html('<table width="600" >')
  end

  def test_assert_html_equal_passes_for_whitespace_only_diff
    # These are the kind of differences between JS template literals and Ruby heredocs
    js_style = <<~HTML
      <div
         class="foo"
      >
        <p>content</p>
      </div>
    HTML
    ruby_style = <<~HTML
      <div class="foo">
        <p>content</p>
      </div>
    HTML

    assert_html_equal js_style, ruby_style
  end

  def test_assert_html_equal_matches_body_with_double_space
    # JS: <body  style="...">  Ruby: <body style="...">
    assert_html_equal '<body  style="word-spacing:normal;">',
      '<body style="word-spacing:normal;">'
  end

  def test_assert_html_equal_fails_for_content_diff
    err = assert_raises(Minitest::Assertion) do
      assert_html_equal "<div>hello</div>", "<div>world</div>"
    end
    assert_includes err.message, "HTML mismatch"
  end

  def test_assert_html_equal_includes_custom_message
    err = assert_raises(Minitest::Assertion) do
      assert_html_equal "<a>", "<b>", "context info"
    end
    assert_includes err.message, "context info"
  end

  def test_assert_html_has_finds_element
    html = '<div role="article"><p class="intro">Hello</p></div>'
    assert_html_has html, "p.intro"
    assert_html_has html, "div[role='article']"
  end

  def test_assert_html_has_checks_text
    html = "<div><p>Hello World</p></div>"
    assert_html_has html, "p", text: "Hello"
  end

  def test_assert_html_has_checks_attrs
    html = '<table role="presentation" border="0"></table>'
    assert_html_has html, "table", attrs: {role: "presentation", border: "0"}
  end

  def test_assert_html_has_fails_for_missing_element
    html = "<div>content</div>"
    err = assert_raises(Minitest::Assertion) do
      assert_html_has html, "span.missing"
    end
    assert_includes err.message, "span.missing"
  end

  def test_refute_html_has
    html = "<div>content</div>"
    refute_html_has html, "span"
  end

  def test_count_html_nodes
    html = "<ul><li>1</li><li>2</li><li>3</li></ul>"
    assert_equal 3, count_html_nodes(html, "li")
    assert_equal 0, count_html_nodes(html, "span")
  end

  def test_extract_style
    html = '<div style="color:red;font-size:13px;">hi</div>'
    assert_equal "color:red;font-size:13px;", extract_style(html, "div")
  end

  def test_extract_style_returns_nil_for_missing
    html = "<div>no style</div>"
    assert_nil extract_style(html, "div")
    assert_nil extract_style(html, "span")
  end

  def test_extract_css_property
    assert_equal "13px", extract_css_property("color:red;font-size:13px;", "font-size")
    assert_equal "red", extract_css_property("color:red;font-size:13px;", "color")
    assert_nil extract_css_property("color:red;", "font-size")
    assert_nil extract_css_property(nil, "color")
  end

  def test_extract_css_property_handles_first_property
    assert_equal "#000000", extract_css_property("color:#000000;font-size:13px;", "color")
  end

  def test_render_helper
    html = render("<mjml><mj-body><mj-section><mj-column><mj-text>OK</mj-text></mj-column></mj-section></mj-body></mjml>")
    assert_includes html, "OK"
    assert_includes html, "<!doctype html>"
  end
end
