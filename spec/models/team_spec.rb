# frozen_string_literal: true

require "rails_helper"

RSpec.describe Team, type: :model do
     describe "associations" do
          it { is_expected.to belong_to(:ideathon_year) }
          it { is_expected.to have_many(:registered_attendees) }
     end

     describe "validations" do
          let(:ideathon_year) do
               IdeathonYear.create!(
                 name: "Ideathon 2030",
                 start_date: 2.years.from_now,
                 end_date: 2.years.from_now + 1.day,
                 is_active: true
               )
          end

          it "rejects duplicate team names in the same year when casing differs" do
               Team.create!(ideathon_year: ideathon_year, team_name: "Alpha", unassigned: false)
               duplicate = Team.new(ideathon_year: ideathon_year, team_name: "alpha", unassigned: false)
               expect(duplicate).not_to be_valid
               expect(duplicate.errors[:team_name]).to include("already exists for this year")
          end

          it "normalizes whitespace so names match after squish" do
               Team.create!(ideathon_year: ideathon_year, team_name: "Beta Team", unassigned: false)
               duplicate = Team.new(ideathon_year: ideathon_year, team_name: "  Beta Team  ", unassigned: false)
               expect(duplicate).not_to be_valid
          end

          it "does not enforce uniqueness on unassigned teams" do
               Team.create!(ideathon_year: ideathon_year, team_name: "Unassigned", unassigned: true)
               second = Team.new(ideathon_year: ideathon_year, team_name: "Unassigned", unassigned: true)
               expect(second).to be_valid
          end
     end
end
