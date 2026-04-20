require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#rule_title_and_body" do
    it "splits on a blank line into title and body" do
      rule = double("Rule", rule_text: "Title Here\n\nBody text")
      expect(helper.rule_title_and_body(rule)).to eq(
        title: "Title Here",
        body: "Body text"
      )
    end

    it "returns a single body when there is no paragraph split" do
      rule = double("Rule", rule_text: "Only one block")
      expect(helper.rule_title_and_body(rule)).to eq(
        title: nil,
        body: "Only one block"
      )
    end
  end

  describe "#faq_answer_html" do
    it "allows safe tags and strips the rest" do
      html = helper.faq_answer_html('<p>Hi</p><script>x</script><strong>bold</strong>')
      expect(html).to include("<p>")
      expect(html).to include("<strong>")
      expect(html).not_to include("script")
    end
  end

  describe "#context_field_tip" do
    it "wraps content in a div with data-tip from i18n" do
      html = helper.context_field_tip("users.email") { "inner" }
      expect(html).to include('class="context-field-tip"')
      expect(html).to include("data-tip")
      expect(html).to include(I18n.t("context_help.users.email"))
      expect(html).to include("inner")
    end
  end

  describe "#sponsor_logo_or_name" do
    let(:sponsor_with_logo) { double("SponsorsPartner", name: "Acme", logo_url: "https://example.com/logo.png") }
    let(:sponsor_without_logo) { double("SponsorsPartner", name: "Acme", logo_url: nil) }

    it "renders image with hidden fallback when logo exists" do
      html = helper.sponsor_logo_or_name(
        sponsor_with_logo,
        image_class: "logo-class",
        fallback_class: "fallback-class",
        fallback_tag: :div
      )

      expect(html).to include("img")
      expect(html).to include("logo-class")
      expect(html).to include("onerror")
      expect(html).to include("hidden fallback-class")
      expect(html).to include("Acme")
    end

    it "renders image without hidden fallback when error fallback is disabled" do
      html = helper.sponsor_logo_or_name(
        sponsor_with_logo,
        image_class: "logo-class",
        fallback_class: "fallback-class",
        fallback_tag: :span,
        show_fallback_on_logo_error: false
      )

      expect(html).to include("<img")
      expect(html).to include("logo-class")
      expect(html).not_to include("onerror")
      expect(html).not_to include("hidden fallback-class")
    end

    it "renders visible fallback when logo is missing" do
      html = helper.sponsor_logo_or_name(
        sponsor_without_logo,
        image_class: "logo-class",
        fallback_class: "fallback-class",
        fallback_tag: :div
      )

      expect(html).not_to include("<img")
      expect(html).to include("fallback-class")
      expect(html).to include("Acme")
    end

    it "renders nothing when missing logo and fallback disabled" do
      html = helper.sponsor_logo_or_name(
        sponsor_without_logo,
        image_class: "logo-class",
        fallback_class: "fallback-class",
        fallback_tag: :span,
        show_fallback_when_logo_missing: false
      )

      expect(html).to eq("")
    end
  end
end
