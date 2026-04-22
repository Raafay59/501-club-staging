require "rails_helper"

RSpec.describe "Google OAuth sign-in (admin)", type: :system do
     before { OmniAuth.config.test_mode = true }
     after do
          OmniAuth.config.mock_auth[:google_oauth2] = nil
          OmniAuth.config.test_mode = false
     end

     context "when user is not signed in" do
          it "shows home page with login and register options" do
               visit root_path
               expect(page).to have_current_path(root_path, ignore_query: true)
               expect(page).to have_content("Register")
               expect(page).to have_content("Login")
          end
     end

     context "when email is on the admin allowlist (pre-validated)" do
          before do
               @orig_allowlist = ENV["ALLOWED_ADMIN_EMAILS"]
               ENV["ALLOWED_ADMIN_EMAILS"] = "admin@tamu.edu"
               mock_google_oauth2(email: "admin@tamu.edu", full_name: "Admin User", uid: "123", avatar_url: "https://example.com/a.jpg")
               visit new_admin_session_path
               click_button "Sign in with Google"
          end

          after do
               if @orig_allowlist.nil?
                    ENV.delete("ALLOWED_ADMIN_EMAILS")
               else
                    ENV["ALLOWED_ADMIN_EMAILS"] = @orig_allowlist
               end
          end

          it "signs them in as admin and redirects to admin dashboard" do
               expect(Admin.find_by(email: "admin@tamu.edu")).to be_present
               expect(page).to have_current_path(manager_index_path, ignore_query: true)
               expect(page).to have_content("Manager Dashboard")
          end
     end

     context "when email is not on the admin allowlist" do
          before do
               @orig_allowlist = ENV["ALLOWED_ADMIN_EMAILS"]
               ENV["ALLOWED_ADMIN_EMAILS"] = "other@tamu.edu"
               mock_google_oauth2(email: "user@gmail.com", full_name: "Regular User", uid: "456", avatar_url: nil)
               visit new_admin_session_path
               click_button "Sign in with Google"
          end

          after do
               if @orig_allowlist.nil?
                    ENV.delete("ALLOWED_ADMIN_EMAILS")
               else
                    ENV["ALLOWED_ADMIN_EMAILS"] = @orig_allowlist
               end
          end

          it "does not grant access and shows error about admin privileges" do
               expect(Admin.find_by(email: "user@gmail.com")).to be_nil
               expect(page).to have_current_path(new_admin_session_path, ignore_query: true)
               expect(page).to have_content("user@gmail.com is not authorized as an admin.")
          end
     end
end
