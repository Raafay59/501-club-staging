require "rails_helper"

RSpec.describe Faq, type: :model do
     let!(:ideathon) { Ideathon.create!(year: 2026, name: "Ideathon 2026") }

     it "validates required fields" do
          faq = described_class.new
          expect(faq).not_to be_valid
          expect(faq.errors[:question]).to be_present
          expect(faq.errors[:answer]).to be_present
     end

     it "maps year to ideathon association" do
          faq = described_class.new(question: "Q", answer: "A")
          faq.year = 2026
          expect(faq.ideathon).to eq(ideathon)
     end

     it "clears ideathon when year is blank" do
          faq = described_class.new(question: "Q", answer: "A", ideathon: ideathon)
          faq.year = ""
          expect(faq.ideathon).to be_nil
     end
end
