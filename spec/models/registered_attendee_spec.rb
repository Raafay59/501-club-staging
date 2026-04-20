require "rails_helper"

RSpec.describe RegisteredAttendee, type: :model do
  let!(:ideathon) do
    Ideathon.create!(
      year: 2025,
      theme: "Tech",
      is_active: true,
      start_date: Date.new(2025, 2, 1),
      end_date: Date.new(2025, 2, 2)
    )
  end
  let!(:team) { Team.create!(ideathon_year: ideathon, team_name: "Alpha", unassigned: false) }

  def valid_attributes(overrides = {})
    {
      ideathon_year: ideathon,
      team: team,
      attendee_name: "Pat Example",
      attendee_phone: "9795551234",
      attendee_email: "pat@tamu.edu",
      attendee_major: "CS",
      attendee_class: "U2"
    }.merge(overrides)
  end

  describe ".search_by_name" do
    it "filters by attendee name when query is present" do
      match = RegisteredAttendee.create!(valid_attributes(attendee_name: "Alex Smith", attendee_email: "alex@tamu.edu"))
      RegisteredAttendee.create!(valid_attributes(attendee_name: "Jordan Lee", attendee_email: "jordan@tamu.edu"))

      results = RegisteredAttendee.search_by_name("Alex")

      expect(results).to include(match)
      expect(results.map(&:attendee_name)).not_to include("Jordan Lee")
    end
  end

  describe "phone validation" do
    it "requires exactly 10 digits after stripping punctuation" do
      attendee = RegisteredAttendee.new(valid_attributes(attendee_phone: "979-555-123"))

      expect(attendee).not_to be_valid
      expect(attendee.errors[:attendee_phone]).to include("must contain exactly 10 digits")
    end
  end
end
