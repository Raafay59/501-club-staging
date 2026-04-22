require "rails_helper"

RSpec.describe ActivityLog, type: :model do
     let(:admin) { Admin.create!(email: "log-admin@tamu.edu", full_name: "Log Admin", uid: "log-1") }

     describe ".infer_metadata" do
          it "classifies sponsor, ideathon, and unknown messages" do
               sponsor = described_class.infer_metadata("Sponsor 'ACME' was added")
               ideathon = described_class.infer_metadata("Ideathon 2026 was edited")
               unknown = described_class.infer_metadata("Something else happened")

               expect(sponsor).to eq(content_type: "sponsors", item_name: "ACME")
               expect(ideathon).to eq(content_type: "ideathons", item_name: "2026")
               expect(unknown[:content_type]).to eq("activity")
          end
     end

     describe ".record!" do
          it "creates row with inferred metadata when not provided" do
               log = described_class.record!(admin: admin, action: :added, message: "FAQ 'Q1' was added")
               expect(log.content_type).to eq("faqs")
               expect(log.item_name).to eq("Q1")
               expect(log.actor_email).to eq(admin.email)
          end
     end

     describe ".filter" do
          it "filters by content type and custom date range" do
               old_log = described_class.create!(
                 admin: admin, actor_name: "A", actor_email: admin.email,
                 action: "added", content_type: "faqs", item_name: "Old", message: "FAQ 'Old' was added",
                 created_at: 10.days.ago
               )
               new_log = described_class.create!(
                 admin: admin, actor_name: "A", actor_email: admin.email,
                 action: "added", content_type: "faqs", item_name: "New", message: "FAQ 'New' was added",
                 created_at: 1.day.ago
               )

               results = described_class.filter(content_type: "faqs", date_range: "last_7_days")
               expect(results).to include(new_log)
               expect(results).not_to include(old_log)
          end

          it "includes import/export log content types in category filters" do
               sponsor_import = described_class.create!(
                 admin: admin,
                 actor_name: "A",
                 actor_email: admin.email,
                 action: "imported",
                 content_type: "sponsors_partners",
                 item_name: "2 sponsors/partners",
                 message: "Imported 2 sponsors/partners"
               )
               mentor_export = described_class.create!(
                 admin: admin,
                 actor_name: "A",
                 actor_email: admin.email,
                 action: "exported",
                 content_type: "mentors_judges",
                 item_name: "3 mentors/judges",
                 message: "Exported 3 mentors/judges"
               )

               sponsor_results = described_class.filter(content_type: "sponsors")
               judge_results = described_class.filter(content_type: "judges")

               expect(sponsor_results).to include(sponsor_import)
               expect(judge_results).to include(mentor_export)
          end
     end

     describe "immutability" do
          it "prevents updates and deletions" do
               log = described_class.create!(
                 admin: admin, actor_name: "A", actor_email: admin.email,
                 action: "added", content_type: "faqs", item_name: "Q", message: "FAQ 'Q' was added"
               )

               expect(log.update(message: "changed")).to eq(false)
               expect(log.destroy).to eq(false)
          end
     end
end
