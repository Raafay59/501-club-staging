require "rails_helper"

RSpec.describe "ActivityLogs dashboard", type: :request do
     let(:admin_user) { Admin.create!(email: "logs-admin@tamu.edu", full_name: "Admin", uid: "logs-a", role: "admin") }
     let(:unauthorized_user) { Admin.create!(email: "logs-unauth@tamu.edu", full_name: "No Access", uid: "logs-u", role: "unauthorized") }

     before do
          ActivityLog.create!(
            admin: admin_user,
            actor_name: "Admin",
            actor_email: admin_user.email,
            action: "added",
            content_type: "faqs",
            item_name: "Q1",
            message: "FAQ 'Q1' was added"
          )
     end

     it "redirects guests to sign in" do
          get activity_logs_path
          expect(response).to redirect_to(new_admin_session_path)
     end

     it "blocks unauthorized dashboard accounts" do
          sign_in unauthorized_user, scope: :admin
          get activity_logs_path
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to match(/not authorized/i)
     end

     it "renders index for authorized admins" do
          sign_in admin_user, scope: :admin
          get activity_logs_path
          expect(response).to have_http_status(:ok)
          expect(response.body).to include("Q1")
     end

     it "handles invalid custom date ranges with alert" do
          sign_in admin_user, scope: :admin
          get activity_logs_path, params: {
            date_range: "custom",
            start_date: "2026-12-10",
            end_date: "2026-12-01"
          }
          expect(response).to have_http_status(:ok)
          expect(response.body).to include("End date must be on or after start date.")
     end
end
