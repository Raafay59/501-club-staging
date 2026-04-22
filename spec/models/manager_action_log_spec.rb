# frozen_string_literal: true

require "rails_helper"

RSpec.describe ManagerActionLog, type: :model do
     let(:admin) { Admin.create!(email: "admin@tamu.edu", full_name: "Admin", uid: "123") }

     describe "labels" do
          it "formats created attendee rows clearly" do
               log = described_class.create!(
                 admin: admin,
                 action: "attendee.created",
                 metadata: { "record_name" => "Jane Doe" }
               )

               expect(log.action_label).to eq("Created")
               expect(log.target_label).to eq("Attendee")
               expect(log.record_label).to eq("Jane Doe")
               expect(log.details_label).to eq("—")
          end

          it "formats event update rows clearly" do
               log = described_class.create!(
                 admin: admin,
                 action: "event.updated",
                 metadata: { "record_name" => "Kickoff" }
               )

               expect(log.action_label).to eq("Updated")
               expect(log.target_label).to eq("Event")
               expect(log.record_label).to eq("Kickoff")
          end

          it "formats deleted rows clearly" do
               log = described_class.create!(
                 admin: admin,
                 action: "event.deleted",
                 metadata: { "record_name" => "Check-in" }
               )

               expect(log.action_label).to eq("Deleted")
               expect(log.target_label).to eq("Event")
               expect(log.record_label).to eq("Check-in")
               expect(log.details_label).to eq("—")
          end

          it "humanizes unknown action labels" do
               log = described_class.create!(
                 admin: admin,
                 action: "custom.action_name",
                 metadata: {}
               )

               expect(log.action_label).to eq("Custom Action Name")
          end

          it "falls back target label to record_type" do
               log = described_class.create!(
                 admin: admin,
                 action: "custom.updated",
                 record_type: "MyModel",
                 record_id: 9,
                 metadata: {}
               )

               expect(log.target_label).to eq("MyModel")
          end

          it "formats export rows clearly" do
               log = described_class.create!(
                 admin: admin,
                 action: "export.teams_csv",
                 metadata: { "count" => 20 }
               )

               expect(log.action_label).to eq("Exported")
               expect(log.target_label).to eq("Export")
               expect(log.record_label).to eq("Teams CSV")
               expect(log.details_label).to eq("20 rows")
          end

          it "formats participants export label" do
               log = described_class.create!(
                 admin: admin,
                 action: "export.participants_csv",
                 metadata: {}
               )

               expect(log.record_label).to eq("Participants CSV")
          end

          it "formats unknown export as CSV" do
               log = described_class.create!(
                 admin: admin,
                 action: "export.anything",
                 metadata: {}
               )

               expect(log.record_label).to eq("CSV")
          end

          it "falls back to attendee_name in metadata for record label" do
               log = described_class.create!(
                 admin: admin,
                 action: "attendee.updated",
                 metadata: { "attendee_name" => "Fallback Name" }
               )

               expect(log.record_label).to eq("Fallback Name")
          end

          it "falls back to record_type and record_id when metadata name is missing" do
               log = described_class.create!(
                 admin: admin,
                 action: "attendee.updated",
                 record_type: "RegisteredAttendee",
                 record_id: 22,
                 metadata: {}
               )

               expect(log.record_label).to eq("RegisteredAttendee#22")
          end

          it "shows update changes as old to new" do
               log = described_class.create!(
                 admin: admin,
                 action: "attendee.updated",
                 metadata: {
                   "record_name" => "One last time",
                   "changes" => {
                     "attendee_name" => [ "Oscarito", "One last time" ]
                   }
                 }
               )

               expect(log.details_label).to include("Name: Oscarito")
               expect(log.details_label).to include("One last time")
               expect(log.details_label).to include("→")
          end

          it "shows only first 3 changed fields in details" do
               log = described_class.create!(
                 admin: admin,
                 action: "attendee.updated",
                 metadata: {
                   "changes" => {
                     "attendee_name" => [ "A", "B" ],
                     "attendee_email" => [ "a@tamu.edu", "b@tamu.edu" ],
                     "attendee_phone" => [ "1111111111", "2222222222" ],
                     "attendee_major" => [ "CS", "EE" ]
                   }
                 }
               )

               details = log.details_label
               expect(details.split(" · ").size).to eq(3)
               expect(details).to include("Name:")
               expect(details).to include("Email:")
               expect(details).to include("Phone:")
          end

          it "returns dash for updated action when changes are blank" do
               log = described_class.create!(
                 admin: admin,
                 action: "attendee.updated",
                 metadata: { "changes" => {} }
               )

               expect(log.details_label).to eq("—")
          end

          it "returns dash for non-updated actions without count" do
               log = described_class.create!(
                 admin: admin,
                 action: "attendee.created",
                 metadata: {}
               )

               expect(log.details_label).to eq("—")
          end

          it "maps event field labels in update details" do
               log = described_class.create!(
                 admin: admin,
                 action: "event.updated",
                 metadata: {
                   "changes" => {
                     "event_name" => [ "Old title", "New title" ],
                     "event_description" => [ "Old desc", "New desc" ]
                   }
                 }
               )

               expect(log.details_label).to include("Title: Old title → New title")
               expect(log.details_label).to include("Description: Old desc → New desc")
          end
     end
end
