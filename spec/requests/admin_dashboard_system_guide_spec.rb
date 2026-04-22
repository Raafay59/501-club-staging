require "rails_helper"

RSpec.describe "Admin dashboard system guide coverage", type: :request do
     let(:admin_user) { Admin.create!(email: "guide-admin@tamu.edu", full_name: "Guide Admin", uid: "guide-a", role: "admin") }
     let(:editor_user) { Admin.create!(email: "guide-editor@tamu.edu", full_name: "Guide Editor", uid: "guide-e", role: "editor") }
     let(:unauthorized_user) { Admin.create!(email: "guide-unauth@tamu.edu", full_name: "Guide Unauthorized", uid: "guide-u", role: "unauthorized") }

     let(:dashboard_index_routes) do
          [
            manager_index_path,
            ideathons_path,
            sponsors_partners_path,
            mentors_judges_path,
            faqs_path,
            rules_path,
            activity_logs_path,
            users_path
          ]
     end

     it "keeps the public home route accessible" do
          get root_path
          expect(response).to have_http_status(:ok)
     end

     it "requires sign-in for manager and dashboard index routes" do
          dashboard_index_routes.each do |route|
               get route
               expect(response).to redirect_to(new_admin_session_path)
          end
     end

     it "blocks unauthorized role from organizer/dashboard tools" do
          sign_in unauthorized_user, scope: :admin

          [ manager_index_path, ideathons_path, activity_logs_path ].each do |route|
               get route
               expect(response).to redirect_to(root_path)
               expect(flash[:alert]).to match(/not authorized/i)
          end
     end

     it "allows editor access to manager and content dashboards" do
          sign_in editor_user, scope: :admin

          [
            manager_index_path,
            ideathons_path,
            sponsors_partners_path,
            mentors_judges_path,
            faqs_path,
            rules_path,
            activity_logs_path
          ].each do |route|
               get route
               expect(response).to have_http_status(:ok)
          end
     end

     it "restricts users management to admins" do
          sign_in editor_user, scope: :admin
          get users_path
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to eq("Only admins can perform this action.")

          sign_in admin_user, scope: :admin
          get users_path
          expect(response).to have_http_status(:ok)
     end
end
