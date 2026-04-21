require "rails_helper"

RSpec.describe Ideathon, type: :model do
     it "validates year range and uniqueness" do
          Ideathon.create!(year: 2026, name: "Ideathon 2026")
          invalid = Ideathon.new(year: 2026, name: "Duplicate")
          expect(invalid).not_to be_valid
          expect(invalid.errors[:year]).to be_present

          out_of_range = Ideathon.new(year: 1999, name: "Too old")
          expect(out_of_range).not_to be_valid
     end

     it "assigns default name from year when blank" do
          ideathon = Ideathon.create!(year: 2027, name: nil)
          expect(ideathon.name).to eq("Ideathon 2027")
     end

     it "uses year in param" do
          ideathon = Ideathon.create!(year: 2028, name: "Ideathon 2028")
          expect(ideathon.to_param).to eq("2028")
     end
end
