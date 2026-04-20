require "rails_helper"

RSpec.describe Team, type: :model do
  let!(:ideathon) do
    Ideathon.create!(
      year: 2026,
      theme: "Theme",
      is_active: true,
      start_date: Date.new(2026, 2, 1),
      end_date: Date.new(2026, 2, 2)
    )
  end

  describe "normalization" do
    it "strips leading and trailing spaces before validation" do
      team = Team.create!(ideathon_year: ideathon, team_name: "  Squad  ", unassigned: false)

      expect(team.team_name).to eq("Squad")
    end

    it "prevents duplicates that differ only by outer whitespace" do
      Team.create!(ideathon_year: ideathon, team_name: "Squad", unassigned: false)
      dup = Team.new(ideathon_year: ideathon, team_name: "  Squad  ", unassigned: false)

      expect(dup).not_to be_valid
      expect(dup.errors[:team_name]).to include("already exists for this year")
    end

    it "allows only one unassigned team per year" do
      Team.create!(ideathon_year: ideathon, team_name: "Unassigned", unassigned: true)

      another = Team.new(ideathon_year: ideathon, team_name: "Unassigned 2", unassigned: true)

      expect(another).not_to be_valid
      expect(another.errors[:ideathon_year_id]).to include("already has an unassigned team")
    end
  end
end
