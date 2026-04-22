require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
     SponsorStub = Struct.new(:name, :logo_url)

     describe "#rule_title_and_body" do
          it "splits title/body when separated by blank line" do
               rule = Rule.new(rule_text: "Title\n\nBody text")
               result = helper.rule_title_and_body(rule)
               expect(result[:title]).to eq("Title")
               expect(result[:body]).to eq("Body text")
          end

          it "returns full body when no title split exists" do
               rule = Rule.new(rule_text: "Single line rule")
               result = helper.rule_title_and_body(rule)
               expect(result[:title]).to be_nil
               expect(result[:body]).to eq("Single line rule")
          end
     end

     describe "#faq_answer_html" do
          it "sanitizes disallowed html tags" do
               html = helper.faq_answer_html("<strong>ok</strong><script>alert(1)</script>")
               expect(html).to include("<strong>ok</strong>")
               expect(html).not_to include("<script>")
          end
     end

     describe "#sponsor_logo_or_name" do
          it "renders image and fallback wrapper when logo exists and fallback-on-error enabled" do
               sponsor = SponsorStub.new("ACME", "https://example.com/logo.png")
               html = helper.sponsor_logo_or_name(
                 sponsor,
                 image_class: "img",
                 fallback_class: "fallback",
                 fallback_tag: :div,
                 show_fallback_on_logo_error: true
               )
               expect(html).to include("sponsor-logo#handleError")
               expect(html).to include("ACME")
          end

          it "renders plain image when fallback-on-error disabled" do
               sponsor = SponsorStub.new("ACME", "https://example.com/logo.png")
               html = helper.sponsor_logo_or_name(
                 sponsor,
                 image_class: "img",
                 fallback_class: "fallback",
                 fallback_tag: :div,
                 show_fallback_on_logo_error: false
               )
               expect(html).to include("img")
               expect(html).not_to include("sponsor-logo#handleError")
          end

          it "renders fallback name when logo missing and fallback enabled" do
               sponsor = SponsorStub.new("NoLogo", nil)
               html = helper.sponsor_logo_or_name(
                 sponsor,
                 image_class: "img",
                 fallback_class: "fallback",
                 fallback_tag: :span,
                 show_fallback_when_logo_missing: true
               )
               expect(html).to include("NoLogo")
          end

          it "returns empty string when logo missing and fallback disabled" do
               sponsor = SponsorStub.new("NoLogo", nil)
               html = helper.sponsor_logo_or_name(
                 sponsor,
                 image_class: "img",
                 fallback_class: "fallback",
                 fallback_tag: :span,
                 show_fallback_when_logo_missing: false
               )
               expect(html).to eq("")
          end
     end
end
