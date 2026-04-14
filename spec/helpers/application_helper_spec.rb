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
end
