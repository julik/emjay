# frozen_string_literal: true

require "minitest/autorun"
require "nokogiri"
require "emjay"

module EmjayTestHelpers
  # Normalizes an HTML string for comparison by collapsing whitespace
  # differences that don't affect rendering.
  #
  # The JS upstream produces template-literal output where attributes
  # may span multiple lines, extra spaces appear before `>`, and
  # indentation varies. Our Ruby heredocs produce different (but
  # semantically identical) whitespace. This normalizer reconciles both.
  def normalize_html(html)
    out = html.dup

    # Normalize line endings
    out.gsub!("\r\n", "\n")

    # Normalize whitespace inside <style> blocks. MJML 5 pretty-prints CSS
    # (multi-line, spaces after ":") while emjay emits single-line, tight CSS.
    # Both are semantically identical, so within style bodies we collapse
    # whitespace to a single space and then strip it around structural CSS
    # punctuation. Descendant combinators (spaces between selectors) are
    # preserved.
    out.gsub!(/(<style\b[^>]*>)(.*?)(<\/style>)/m) do
      open_tag = $1
      css = $2
      close_tag = $3
      css = css.gsub(/\s+/, " ")
      css.gsub!(/\s*([{};:,~>+!])\s*/, '\1')
      "#{open_tag}#{css.strip}#{close_tag}"
    end

    # Collapse whitespace inside opening tags: <tag \n  attr="val"\n  >
    # becomes <tag attr="val">
    # We handle this by collapsing whitespace between < and > for opening tags,
    # preserving attribute content.
    out.gsub!(/(<[a-zA-Z][^>]*?)(\s+)(>)/) do
      "#{$1.strip}#{$3}"
    end

    # Collapse runs of whitespace inside opening tags (between tag name and attributes)
    # e.g. <body  style= → <body style=
    # This needs to be done carefully to avoid mangling attribute values.
    out.gsub!(/<([a-zA-Z][a-zA-Z0-9:-]*)((?:\s+[^>]*?)?)>/m) do
      tag = $1
      attrs_str = $2
      # Collapse whitespace between attributes, but not inside quoted values
      normalized_attrs = attrs_str.gsub(/\s+/m, " ").strip
      if normalized_attrs.empty?
        "<#{tag}>"
      else
        "<#{tag} #{normalized_attrs}>"
      end
    end

    # Collapse whitespace between tags (`>   <` → `><`). Whitespace-only text
    # nodes between block-level tags are insignificant and MJML 5 formats them
    # differently from emjay.
    out.gsub!(/>\s+</m, "><")

    # Collapse whitespace inside text nodes and around tag boundaries. MJML 5
    # sometimes emits `<a> Click me </a>` (padded, single line) while emjay
    # emits `<a>\nClick me\n</a>`; both render identically.
    out.gsub!(/>(\s*[^<]+?\s*)</m) do |_m|
      inner = $1.gsub(/\s+/, " ").strip
      ">#{inner}<"
    end

    # Re-insert one newline after every `>` for readable diffs.
    out.gsub!(">", ">\n")

    # Strip leading/trailing whitespace per line
    out.gsub!(/^[ \t]+/, "")
    out.gsub!(/[ \t]+$/, "")

    # Collapse multiple blank lines into one
    out.gsub!(/\n{2,}/, "\n")

    # Normalize random hex IDs used by carousel and navbar hamburger.
    # These are 16-char hex strings that differ between JS and Ruby runs.
    out.gsub!(/([0-9a-f]{16})(?=[^0-9a-f]|$)/) { "NORMALIZED_ID" }

    out.strip
  end

  # Asserts two HTML strings are structurally equivalent — identical
  # content after whitespace normalization. Produces a readable unified
  # diff on failure.
  def assert_html_equal(expected, actual, msg = nil)
    norm_expected = normalize_html(expected)
    norm_actual = normalize_html(actual)

    return if norm_expected == norm_actual

    diff = unified_diff(norm_expected, norm_actual)
    fail_msg = +"HTML mismatch"
    fail_msg << " — #{msg}" if msg
    fail_msg << ":\n#{diff}"
    flunk fail_msg
  end

  # Asserts the HTML contains an element matching the given CSS selector,
  # optionally checking its text content or attribute values.
  #
  #   assert_html_has(html, "div[role='article']")
  #   assert_html_has(html, "div.mj-column-per-100", text: "Hello")
  #   assert_html_has(html, "table", attrs: { role: "presentation" })
  def assert_html_has(html, selector, text: nil, attrs: nil, msg: nil)
    doc = parse_doc(html)
    node = doc.at_css(selector)

    fail_msg = msg || "Expected to find #{selector.inspect}"
    assert node, fail_msg

    if text
      assert_includes node.text, text,
        "#{fail_msg}: expected text #{text.inspect} in #{selector}"
    end

    attrs&.each do |attr_name, attr_value|
      assert_equal attr_value.to_s, node[attr_name.to_s],
        "#{fail_msg}: expected #{attr_name}=#{attr_value.inspect} on #{selector}"
    end
  end

  # Asserts the HTML does NOT contain an element matching the CSS selector.
  def refute_html_has(html, selector, msg: nil)
    doc = parse_doc(html)
    node = doc.at_css(selector)
    fail_msg = msg || "Expected NOT to find #{selector.inspect}"
    refute node, fail_msg
  end

  # Counts elements matching a CSS selector.
  def count_html_nodes(html, selector)
    parse_doc(html).css(selector).length
  end

  # Extracts the inline style string from the first element matching selector.
  # Returns nil if the element or style attribute is missing.
  def extract_style(html, selector)
    parse_doc(html).at_css(selector)&.[]("style")
  end

  # Extracts a single CSS property value from an inline style string.
  #
  #   extract_css_property("color:#000;font-size:13px;", "font-size")
  #   # => "13px"
  def extract_css_property(style_string, property)
    return nil unless style_string
    match = style_string.match(/(?:^|;)\s*#{Regexp.escape(property)}\s*:\s*([^;]+)/)
    match&.[](1)&.strip
  end

  # Renders MJML and returns the HTML string. Convenience for tests that
  # just need to call `render(mjml)` without repeating Emjay.to_html.
  def render(mjml, **options)
    Emjay.to_html(mjml, options)
  end

  private

  def parse_doc(html)
    @_parsed_docs ||= {}
    @_parsed_docs[html.object_id] ||= Nokogiri::HTML(html)
  end

  def unified_diff(expected, actual)
    expected_lines = expected.lines
    actual_lines = actual.lines

    first_diff = nil
    last_diff = nil
    max = [expected_lines.length, actual_lines.length].max

    max.times do |i|
      if expected_lines[i] != actual_lines[i]
        first_diff ||= i
        last_diff = i
      end
    end

    return "" unless first_diff

    ctx = 3
    from = [first_diff - ctx, 0].max
    to = [last_diff + ctx, max - 1].min

    out = +""
    out << "--- expected\n+++ actual\n"
    out << "@@ -#{from + 1},#{to - from + 1} @@\n"

    (from..to).each do |i|
      exp = expected_lines[i]
      act = actual_lines[i]

      if exp == act
        out << " #{exp}"
      else
        out << "-#{exp}" if exp
        out << "+#{act}" if act
      end
    end

    out
  end
end

# Mix into all test classes
Minitest::Test.include(EmjayTestHelpers)
