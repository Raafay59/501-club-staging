require "rails_helper"

RSpec.describe "ActivityLogs", type: :request do
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
