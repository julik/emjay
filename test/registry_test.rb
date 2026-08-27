# frozen_string_literal: true

require_relative "test_helper"

class RegistryTest < Minitest::Test
  def test_find_returns_component_class_for_known_tag
    assert_equal Emjay::Components::MjButton, Emjay::Registry.find("mj-button")
  end

  def test_find_returns_nil_for_unknown_tag
    assert_nil Emjay::Registry.find("mj-nonesuch")
  end

  def test_components_proxy_raises_for_unknown_mj_tag
    err = assert_raises(Emjay::Registry::UnknownComponent) do
      Emjay::Registry.components["mj-nonesuch"]
    end
    assert_includes err.message, "mj-nonesuch"
  end

  def test_components_proxy_returns_nil_for_non_mj_tag
    assert_nil Emjay::Registry.components["div"]
  end

  def test_rendering_unknown_mj_component_raises
    mjml = <<~MJML
      <mjml>
        <mj-body>
          <mj-section>
            <mj-column>
              <mj-nonesuch>oops</mj-nonesuch>
            </mj-column>
          </mj-section>
        </mj-body>
      </mjml>
    MJML

    assert_raises(Emjay::Registry::UnknownComponent) { Emjay.to_html(mjml) }
  end
end
