require "rails_helper"

RSpec.describe "ActivityRecording", type: :request do
  let!(:admin) { User.create!(email: "admin@example.com", role: "admin") }
  let!(:ideathon) { Ideathon.create!(year: 2025, theme: "Tech") }

  before { login_as(admin) }

  describe "automatic create/update/destroy logging" do
    it "records sponsor creation automatically" do
      expect {
        post sponsors_partners_path, params: {
          sponsors_partner: { year: 2025, name: "BigCo", blurb: "Great company", is_sponsor: true }
        }
      }.to change(ActivityLog, :count).by(1)

      log = ActivityLog.last
      expect(log.action).to eq("added")
      expect(log.content_type).to eq("sponsors")
      expect(log.item_name).to eq("BigCo")
      expect(log.message).to eq("Sponsor 'BigCo' was added")
      expect(log.user).to eq(admin)
    end

    it "records photo-only judge updates as photo changes" do
      judge = MentorsJudge.create!(year: 2025, name: "Jane Smith", bio: "Judge", is_judge: true)

      expect {
        patch mentors_judge_path(judge), params: {
          mentors_judge: { photo_url: "http://img.com/jane-updated.jpg" }
        }
      }.to change(ActivityLog, :count).by(1)

      log = ActivityLog.last
      expect(log.action).to eq("edited")
      expect(log.content_type).to eq("photos")
      expect(log.item_name).to eq("Jane Smith")
      expect(log.message).to eq("Photo for judge 'Jane Smith' was updated")
      expect(log.user).to eq(admin)
    end

    it "records FAQ deletion automatically" do
      faq = Faq.create!(year: 2025, question: "What is this?", answer: "A contest.")

      expect {
        delete faq_path(faq)
      }.to change(ActivityLog, :count).by(1)

      log = ActivityLog.last
      expect(log.action).to eq("removed")
      expect(log.content_type).to eq("faqs")
      expect(log.item_name).to eq("What is this?")
      expect(log.message).to eq("FAQ 'What is this?' was removed")
      expect(log.user).to eq(admin)
    end
  end

  describe "bulk import logging" do
    it "records imported rows and a summary entry" do
      file = fixture_file_upload("sponsors_partners.csv", "text/csv")

      expect {
        post import_sponsors_partners_path, params: { file: file }
      }.to change(ActivityLog, :count).by(3)

      summary_log = ActivityLog.order(:id).last
      expect(summary_log.action).to eq("imported")
      expect(summary_log.content_type).to eq("sponsors_partners")
      expect(summary_log.item_name).to eq("2 sponsors/partners")
      expect(summary_log.message).to eq("Imported 2 sponsors/partners")
      expect(summary_log.user).to eq(admin)
    end
  end

  describe "logging failures" do
    it "does not block the original action" do
      allow(ActivityLog).to receive(:create!).and_raise(StandardError, "logging failed")

      expect {
        post sponsors_partners_path, params: {
          sponsors_partner: { year: 2025, name: "Resilient", blurb: "Still saves", is_sponsor: true }
        }
      }.to change(SponsorsPartner, :count).by(1)

      expect(response).to redirect_to(sponsors_partners_path)
    end
  end
end
