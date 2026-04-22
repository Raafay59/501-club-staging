require "rails_helper"

RSpec.describe Rule, type: :model do
     let!(:ideathon) { Ideathon.create!(year: 2026, name: "Ideathon 2026") }

     it "requires rule text and ideathon" do
          rule = described_class.new
          expect(rule).not_to be_valid
          expect(rule.errors[:rule_text]).to be_present
     end

     it "maps year to ideathon" do
          rule = described_class.new(rule_text: "No cheating")
          rule.year = 2026
          expect(rule.ideathon).to eq(ideathon)
     end

     it "raises when assigning unknown year" do
          rule = described_class.new(rule_text: "No cheating")
          expect { rule.year = 2035 }.to raise_error(ActiveRecord::RecordNotFound)
     end
end
