require "rails_helper"

RSpec.describe MentorsJudge, type: :model do
     let!(:ideathon) { Ideathon.create!(year: 2026, name: "Ideathon 2026") }

     it "accepts valid photo url formats" do
          mentor = described_class.new(ideathon: ideathon, name: "Jane", photo_url: "http://example.com/p.png")
          expect(mentor).to be_valid
     end

     it "rejects invalid photo url formats" do
          mentor = described_class.new(ideathon: ideathon, name: "Jane", photo_url: "file://local/path.png")
          expect(mentor).not_to be_valid
          expect(mentor.errors[:photo_url]).to be_present
     end

     it "supports year assignment via ideathon lookup" do
          mentor = described_class.new(name: "Judge Jane")
          mentor.year = 2026
          expect(mentor.ideathon).to eq(ideathon)
          expect(mentor.year).to eq(2026)
     end
end
