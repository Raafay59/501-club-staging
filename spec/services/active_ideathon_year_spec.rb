require "rails_helper"

RSpec.describe ActiveIdeathonYear do
     describe ".call" do
          it "returns explicitly active ideathon year when present" do
               inactive = IdeathonYear.create!(year: 2025, name: "Ideathon 2025", is_active: false)
               active = IdeathonYear.create!(year: 2026, name: "Ideathon 2026", is_active: true)

               result = described_class.call(prefer_content: true)
               expect(result.id).to eq(active.id)
               expect(result.id).not_to eq(inactive.id)
          end

          it "prefers latest content-bearing year when no active year exists" do
               y2025 = IdeathonYear.create!(year: 2025, name: "Ideathon 2025", is_active: false)
               y2026 = IdeathonYear.create!(year: 2026, name: "Ideathon 2026", is_active: false)
               Faq.create!(ideathon_year_id: y2025.id, question: "Q", answer: "A")
               Rule.create!(ideathon_year_id: y2026.id, rule_text: "Rule for 2026")

               result = described_class.call(prefer_content: true)
               expect(result.year).to eq(2026)
          end

          it "falls back to latest year without prefer_content" do
               IdeathonYear.create!(year: 2024, name: "Ideathon 2024", is_active: false)
               newest = IdeathonYear.create!(year: 2027, name: "Ideathon 2027", is_active: false)

               result = described_class.call(prefer_content: false)
               expect(result.id).to eq(newest.id)
          end

          it "creates a default year when requested and missing" do
               IdeathonYear.delete_all
               result = described_class.call(create_if_missing: true)

               expect(result).to be_present
               expect(result.is_active).to eq(true)
               expect(result.year).to eq(Time.zone.today.year)
          end
     end
end
