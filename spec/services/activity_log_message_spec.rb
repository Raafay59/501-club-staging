require "rails_helper"

RSpec.describe ActivityLogMessage do
     let!(:ideathon) { Ideathon.create!(year: 2026, name: "Ideathon 2026") }

     describe ".entry_for" do
          it "builds sponsor message for added action" do
               sponsor = SponsorsPartner.new(ideathon: ideathon, name: "ACME", is_sponsor: true)
               entry = described_class.entry_for(sponsor, :added)

               expect(entry[:content_type]).to eq("sponsors")
               expect(entry[:message]).to include("Sponsor 'ACME' was added")
          end

          it "builds photo update message for logo-only edits" do
               sponsor = SponsorsPartner.new(ideathon: ideathon, name: "ACME", is_sponsor: true)
               entry = described_class.entry_for(sponsor, :edited, saved_changes: { "logo_url" => [ nil, "https://a.com/logo.png" ] })

               expect(entry[:content_type]).to eq("photos")
               expect(entry[:message]).to include("Logo for sponsor 'ACME' was updated")
          end

          it "builds mentor message for removed action" do
               mentor = MentorsJudge.new(ideathon: ideathon, name: "Jane Mentor", is_judge: false)
               entry = described_class.entry_for(mentor, :removed)

               expect(entry[:content_type]).to eq("mentors")
               expect(entry[:message]).to include("Mentor 'Jane Mentor' was removed")
          end

          it "builds faq and rule entries" do
               faq = Faq.new(ideathon: ideathon, question: "Where is check-in?", answer: "MSC")
               rule = Rule.new(ideathon: ideathon, rule_text: "No cheating")

               expect(described_class.entry_for(faq, :edited)[:content_type]).to eq("faqs")
               expect(described_class.entry_for(rule, :added)[:content_type]).to eq("rules")
          end
     end

     describe ".import_entry_for and .export_entry_for" do
          it "formats singular and plural nouns correctly" do
               import_entry = described_class.import_entry_for("Rule", 1)
               export_entry = described_class.export_entry_for("Rule", 2)

               expect(import_entry[:message]).to eq("Imported 1 rule")
               expect(export_entry[:message]).to eq("Exported 2 rules")
          end
     end

     describe ".meaningful_keys" do
          it "drops updated_at from change keys" do
               keys = described_class.meaningful_keys({ "name" => [ "A", "B" ], "updated_at" => [ Time.current, Time.current ] })
               expect(keys).to eq([ "name" ])
          end
     end
end
