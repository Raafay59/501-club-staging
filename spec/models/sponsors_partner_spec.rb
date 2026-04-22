require "rails_helper"

RSpec.describe SponsorsPartner, type: :model do
     let!(:ideathon) { Ideathon.create!(year: 2026, name: "Ideathon 2026") }

     it "accepts valid https logo url" do
          sponsor = described_class.new(ideathon: ideathon, name: "ACME", logo_url: "https://example.com/logo.png")
          expect(sponsor).to be_valid
     end

     it "rejects invalid logo urls" do
          sponsor = described_class.new(ideathon: ideathon, name: "ACME", logo_url: "ftp://example.com/logo.png")
          expect(sponsor).not_to be_valid
          expect(sponsor.errors[:logo_url]).to be_present
     end

     it "maps year to ideathon and exposes year reader" do
          sponsor = described_class.new(name: "ACME")
          sponsor.year = 2026
          expect(sponsor.ideathon).to eq(ideathon)
          expect(sponsor.year).to eq(2026)
     end
end
