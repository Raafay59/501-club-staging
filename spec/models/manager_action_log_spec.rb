require "rails_helper"

RSpec.describe ManagerActionLog, type: :model do
  describe "#action_label" do
    it "labels export actions" do
      expect(described_class.new(action: "export.participants").action_label).to eq("Exported")
    end

    it "labels created / updated / deleted suffixes" do
      expect(described_class.new(action: "event.created").action_label).to eq("Created")
      expect(described_class.new(action: "event.updated").action_label).to eq("Updated")
      expect(described_class.new(action: "event.deleted").action_label).to eq("Deleted")
    end

    it "titleizes other dotted actions" do
      expect(described_class.new(action: "foo.bar_baz").action_label).to eq("Foo Bar Baz")
    end
  end

  describe "#target_label" do
    it "returns Export for export.*" do
      expect(described_class.new(action: "export.teams").target_label).to eq("Export")
    end

    it "returns Attendee / Event for prefixes" do
      expect(described_class.new(action: "attendee.updated").target_label).to eq("Attendee")
      expect(described_class.new(action: "event.created").target_label).to eq("Event")
    end

    it "falls back to record_type or em dash" do
      expect(described_class.new(action: "other", record_type: "RegisteredAttendee").target_label).to eq("RegisteredAttendee")
      expect(described_class.new(action: "other", record_type: "").target_label).to eq("—")
    end
  end

  describe "#record_label" do
    it "labels export actions" do
      expect(
        described_class.new(action: "export.participants").record_label
      ).to eq("Participants CSV")
      expect(
        described_class.new(action: "export.teams").record_label
      ).to eq("Teams CSV")
      expect(
        described_class.new(action: "export.other").record_label
      ).to eq("CSV")
    end

    it "prefers metadata record_name" do
      log = described_class.new(
        action: "event.updated",
        metadata: { "record_name" => "Opening" }
      )
      expect(log.record_label).to eq("Opening")
    end

    it "uses attendee_name or event_name from metadata" do
      expect(
        described_class.new(action: "x", metadata: { "attendee_name" => "Pat" }).record_label
      ).to eq("Pat")
      expect(
        described_class.new(action: "x", metadata: { "event_name" => "Talk" }).record_label
      ).to eq("Talk")
    end

    it "falls back to record_type#id when present" do
      log = described_class.new(action: "x", record_type: "Team", record_id: 9)
      expect(log.record_label).to eq("Team#9")
    end

    it "returns nil when there is no label source" do
      expect(described_class.new(action: "x", record_type: nil, record_id: nil).record_label).to be_nil
    end
  end

  describe "#details_label" do
    it "shows row count when metadata includes count" do
      log = described_class.new(
        action: "export.participants",
        metadata: { "count" => 12 }
      )
      expect(log.details_label).to eq("12 rows")
    end

    it "summarizes field changes for *.updated actions" do
      log = described_class.new(
        action: "event.updated",
        metadata: {
          "changes" => {
            "event_name" => [ "Old", "New Title" ],
            "event_description" => [ "a", "b" ],
            "event_date" => [ Date.new(2025, 1, 1), Date.new(2025, 2, 1) ],
            "event_time" => [ "09:00", "10:00" ]
          }
        }
      )
      expect(log.details_label).to include("Title:")
      expect(log.details_label).to include("Old")
      expect(log.details_label).to include("New Title")
    end

    it "skips unchanged pairs and invalid change entries" do
      log = described_class.new(
        action: "attendee.updated",
        metadata: {
          "changes" => {
            "attendee_name" => [ "Same", "Same" ],
            "attendee_email" => [ "a", "b" ],
            "bad" => "not-an-array"
          }
        }
      )
      expect(log.details_label).to include("Email:")
    end

    it "includes attendee field labels and truncates long values" do
      long = "y" * 100
      log = described_class.new(
        action: "attendee.updated",
        metadata: {
          "changes" => {
            "attendee_phone" => [ "9791112222", "9793334444" ],
            "attendee_major" => [ "", "CSCE" ],
            "attendee_class" => [ "U1", "U2" ],
            "team_id" => [ 1, 2 ]
          }
        }
      )
      expect(log.details_label).to include("Phone:")
      expect(log.details_label).to include("Major:")
      expect(log.details_label).to include("Class:")

      log2 = described_class.new(
        action: "attendee.updated",
        metadata: {
          "changes" => {
            "attendee_name" => [ "a", long ]
          }
        }
      )
      expect(log2.details_label).to include("yyy...")
    end

    it "limits to three change chunks" do
      log = described_class.new(
        action: "event.updated",
        metadata: {
          "changes" => {
            "event_name" => [ "a", "b" ],
            "event_description" => [ "c", "d" ],
            "event_date" => [ Date.new(2025, 1, 1), Date.new(2025, 1, 2) ],
            "event_time" => [ "09:00", "10:00" ]
          }
        }
      )
      expect(log.details_label.split("·").size).to eq(3)
    end

    it "returns em dash when there is nothing to show" do
      expect(described_class.new(action: "event.created").details_label).to eq("—")
      expect(
        described_class.new(action: "event.updated", metadata: {}).details_label
      ).to eq("—")
    end
  end

  describe "private label helpers" do
    let(:log) { described_class.new(action: "event.updated") }

    it "title-cases unknown attribute names" do
      expect(log.send(:human_attr, "weird_thing")).to eq("Weird Thing")
    end

    it "normalizes values for display" do
      expect(log.send(:normalize_value, nil)).to eq("")
      expect(log.send(:normalize_value, "  x  ")).to eq("x")
    end

    it "truncates long strings for diff display" do
      expect(log.send(:truncate_value, "")).to eq("—")
      expect(log.send(:truncate_value, "short")).to eq("short")
      long = "z" * 100
      expect(log.send(:truncate_value, long).length).to eq(80)
      expect(log.send(:truncate_value, long)).to end_with("...")
    end
  end
end
