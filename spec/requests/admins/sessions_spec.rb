require "rails_helper"

RSpec.describe "Admins::Sessions", type: :request do
     let(:admin) { Admin.create!(email: "admin@tamu.edu", full_name: "Admin", uid: "123") }

     describe "GET /admins/sign_in" do
          it "returns success (page with Google sign-in button; email choice happens on Google’s side)" do
               get new_admin_session_path
               expect(response).to have_http_status(:ok)
          end
     end

     describe "DELETE /admins/sign_out" do
           it "redirects to sign-in page after sign out" do
                sign_in admin, scope: :admin
                delete destroy_admin_session_path
                expect(response).to redirect_to(new_admin_session_path)
           end
      end
end
