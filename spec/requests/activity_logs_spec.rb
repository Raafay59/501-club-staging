require "rails_helper"

RSpec.describe "ActivityLogs", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let!(:admin) { User.create!(email: "admin@example.com", name: "Admin User", role: "admin") }
  let!(:editor) { User.create!(email: "editor@example.com", name: "Editor User", role: "editor") }
  let!(:unauthorized) { User.create!(email: "bad@example.com", role: "unauthorized") }

  describe "GET /activity_logs" do
    context "when logged in as an organizer (admin)" do
      before { login_as(admin) }

      it "returns a successful response" do
        get activity_logs_path
        expect(response).to have_http_status(:ok)
      end

      it "lists entries newest first" do
        ActivityLog.record!(user: admin, action: "added", message: "First")
        ActivityLog.record!(user: admin, action: "added", message: "Second")
        get activity_logs_path
        expect(response.body).to match(/Second.*First/m)
      end

      it "filters by content type" do
        ActivityLog.record!(user: admin, action: "added", message: "Sponsor 'Acme' was added")
        ActivityLog.record!(user: admin, action: "added", message: "FAQ 'How do I join?' was added")

        get activity_logs_path, params: { content_type: "sponsors" }

        expect(response.body).to include("Acme")
        expect(response.body).not_to include("How do I join?")
      end

      it "filters by last 7 days" do
        recent_log = ActivityLog.record!(user: admin, action: "added", message: "Sponsor 'Recent' was added")
        older_log = ActivityLog.record!(user: admin, action: "added", message: "Sponsor 'Older' was added")
        recent_log.update_column(:created_at, 2.days.ago)
        older_log.update_column(:created_at, 10.days.ago)

        get activity_logs_path, params: { date_range: "last_7_days" }

        expect(response.body).to include("Recent")
        expect(response.body).not_to include("Older")
      end

      it "combines the content type and date filters" do
        matching_log = ActivityLog.record!(user: admin, action: "added", message: "Sponsor 'Fresh' was added")
        old_sponsor_log = ActivityLog.record!(user: admin, action: "added", message: "Sponsor 'Stale' was added")
        faq_log = ActivityLog.record!(user: admin, action: "added", message: "FAQ 'Still fresh' was added")

        matching_log.update_column(:created_at, 1.day.ago)
        old_sponsor_log.update_column(:created_at, 9.days.ago)
        faq_log.update_column(:created_at, 1.day.ago)

        get activity_logs_path, params: { content_type: "sponsors", date_range: "last_7_days" }

        expect(response.body).to include("Fresh")
        expect(response.body).not_to include("Stale")
        expect(response.body).not_to include("Still fresh")
      end

      it "filters by a custom date range" do
        march_log = ActivityLog.record!(user: admin, action: "added", message: "Judge 'March Match' was added")
        april_log = ActivityLog.record!(user: admin, action: "added", message: "Judge 'April Miss' was added")
        march_log.update_column(:created_at, Time.zone.parse("2026-03-15 12:00:00"))
        april_log.update_column(:created_at, Time.zone.parse("2026-04-01 12:00:00"))

        get activity_logs_path, params: {
          content_type: "judges",
          date_range: "custom",
          start_date: "2026-03-10",
          end_date: "2026-03-20"
        }

        expect(response.body).to include("March Match")
        expect(response.body).not_to include("April Miss")
      end

      it "shows a no-results message for unmatched filters" do
        ActivityLog.record!(user: admin, action: "added", message: "Sponsor 'Acme' was added")

        get activity_logs_path, params: { content_type: "photos" }

        expect(response.body).to include("No changes found for this filter")
      end
    end

    context "when logged in as an organizer (editor)" do
      before { login_as(editor) }

      it "returns a successful response" do
        get activity_logs_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "when logged in as unauthorized" do
      before { login_as(unauthorized) }

      it "redirects away from the activity log" do
        get activity_logs_path
        expect(response).to redirect_to(unauthorized_path)
      end
    end
  end
end
