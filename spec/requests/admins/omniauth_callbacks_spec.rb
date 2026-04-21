# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admins::OmniauthCallbacks", type: :request do
     let(:auth_hash) do
          OmniAuth::AuthHash.new(
            provider: "google_oauth2",
            uid: "123456789",
            info: { email: "admin@tamu.edu", name: "Test Admin", image: "https://example.com/avatar.jpg" },
            credentials: { token: "mock_token", expires_at: 1.week.from_now }
          )
     end

     before { OmniAuth.config.test_mode = true }
     after { OmniAuth.config.mock_auth[:google_oauth2] = nil }

     describe "GET /admins/auth/google_oauth2/callback" do
          context "when the email is in the admin allowlist" do
               before do
                    allow(ENV).to receive(:fetch).with("ALLOWED_ADMIN_EMAILS", "").and_return("admin@tamu.edu")
                    allow_any_instance_of(Admins::OmniauthCallbacksController).to receive(:auth).and_return(auth_hash)
               end

               it "creates a new admin when one does not exist" do
                    expect { get "/admins/auth/google_oauth2/callback" }.to change(Admin, :count).by(1)
               end

               it "redirects to admin dashboard after successful authentication" do
                    get "/admins/auth/google_oauth2/callback"
                    expect(response).to redirect_to(manager_index_path)
               end
          end

          context "when the email is not in the admin allowlist" do
               before do
                    allow(ENV).to receive(:fetch).with("ALLOWED_ADMIN_EMAILS", "").and_return("other@tamu.edu")
                    allow_any_instance_of(Admins::OmniauthCallbacksController).to receive(:auth).and_return(auth_hash)
               end

               it "does not create an admin" do
                    expect { get "/admins/auth/google_oauth2/callback" }.not_to change(Admin, :count)
               end

               it "redirects to sign-in with an error message about admin privileges" do
                    get "/admins/auth/google_oauth2/callback"
                    expect(response).to redirect_to(new_admin_session_path)
                    expect(flash[:alert]).to be_present
                    expect(flash[:alert]).to match(/not authorized|admin/i)
               end
          end
     end
end
