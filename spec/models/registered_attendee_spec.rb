# frozen_string_literal: true

require "rails_helper"

RSpec.describe RegisteredAttendee, type: :model do
     describe "associations" do
          it { is_expected.to belong_to(:ideathon_year) }
          it { is_expected.to belong_to(:team).optional }
     end

     describe "validations" do
          let(:ideathon_year) { IdeathonYear.create!(name: "2026", start_date: 1.week.from_now, end_date: 2.weeks.from_now) }
          let(:team) { Team.create!(ideathon_year: ideathon_year, team_name: "Team A", unassigned: false) }

          it "validates presence of ideathon_year_id, attendee_name, attendee_phone, attendee_email, attendee_major, attendee_class" do
               attendee = RegisteredAttendee.new(ideathon_year: ideathon_year, team: team)
               expect(attendee).not_to be_valid
               expect(attendee.errors[:attendee_name]).to include("can't be blank")
               expect(attendee.errors[:attendee_phone]).to include("can't be blank")
               expect(attendee.errors[:attendee_email]).to include("can't be blank")
               expect(attendee.errors[:attendee_major]).to include("can't be blank")
               expect(attendee.errors[:attendee_class]).to include("can't be blank")
          end

          it "is valid with all required attributes" do
               attendee = RegisteredAttendee.new(
                 ideathon_year: ideathon_year,
                 team: team,
                 attendee_name: "Jane",
                 attendee_phone: "979-555-1234",
                 attendee_email: "jane@tamu.edu",
                 attendee_major: "CS",
                 attendee_class: "Senior"
               )
               expect(attendee).to be_valid
          end
     end

     describe "email acceptance" do
          let(:ideathon_year) { IdeathonYear.create!(name: "2026", start_date: 1.week.from_now, end_date: 2.weeks.from_now) }
          let(:team) { Team.create!(ideathon_year: ideathon_year, team_name: "Team A", unassigned: false) }

          it "is invalid with external email domain" do
               attendee = RegisteredAttendee.new(
                 ideathon_year: ideathon_year,
                 team: team,
                 attendee_name: "Jane",
                 attendee_phone: "979-555-1234",
                 attendee_email: "jane@gmail.com",
                 attendee_major: "CS",
                 attendee_class: "Senior"
               )
               expect(attendee).not_to be_valid
               expect(attendee.errors[:attendee_email]).to include("must be a valid @tamu.edu address")
          end

          it "rejects bare @tamu.edu without a local part" do
               attendee = RegisteredAttendee.new(
                 ideathon_year: ideathon_year,
                 team: team,
                 attendee_name: "NoName",
                 attendee_phone: "979-555-1111",
                 attendee_email: "@tamu.edu",
                 attendee_major: "CS",
                 attendee_class: "Senior"
               )
               expect(attendee).not_to be_valid
               expect(attendee.errors[:attendee_email]).to include("must be a valid @tamu.edu address")
          end

          it "is valid with tamu email domain" do
               attendee = RegisteredAttendee.new(
                 ideathon_year: ideathon_year,
                 team: team,
                 attendee_name: "Bob",
                 attendee_phone: "979-555-5678",
                 attendee_email: "bob@tamu.edu",
                 attendee_major: "EE",
                 attendee_class: "Junior"
               )
               expect(attendee).to be_valid
          end
     end

     describe "scopes" do
          let(:ideathon_year) { IdeathonYear.create!(name: "2026", start_date: 1.week.from_now, end_date: 2.weeks.from_now) }
          let(:team_a) { Team.create!(ideathon_year: ideathon_year, team_name: "Team A", unassigned: false) }
          let(:team_b) { Team.create!(ideathon_year: ideathon_year, team_name: "Team B", unassigned: false) }

          before do
               RegisteredAttendee.create!(ideathon_year: ideathon_year, team: team_a, attendee_name: "Alice", attendee_phone: "979-555-0001", attendee_email: "alice@tamu.edu", attendee_major: "CS", attendee_class: "Sr")
               RegisteredAttendee.create!(ideathon_year: ideathon_year, team: team_a, attendee_name: "Bob", attendee_phone: "979-555-0002", attendee_email: "bob@tamu.edu", attendee_major: "EE", attendee_class: "Jr")
               RegisteredAttendee.create!(ideathon_year: ideathon_year, team: team_b, attendee_name: "Carol", attendee_phone: "979-555-0003", attendee_email: "carol@tamu.edu", attendee_major: "CS", attendee_class: "Sr")
          end

          it "search_by_name filters by name" do
               result = RegisteredAttendee.search_by_name("Alice")
               expect(result.map(&:attendee_name)).to eq([ "Alice" ])
          end

          it "search_by_name_or_team filters by name or team name" do
               result = RegisteredAttendee.search_by_name_or_team("Team B")
               expect(result.map(&:attendee_name)).to include("Carol")
               result2 = RegisteredAttendee.search_by_name_or_team("Bob")
               expect(result2.map(&:attendee_name)).to include("Bob")
          end

          it "sorted_by_team orders by team then name" do
               result = RegisteredAttendee.sorted_by_team
               expect(result.to_a.map(&:attendee_name)).to eq(%w[Alice Bob Carol])
          end
     end
end
