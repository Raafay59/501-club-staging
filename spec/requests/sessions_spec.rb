require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  describe "GET /login" do
    it "returns a successful response" do
      get login_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /auth/google_oauth2/callback" do
    context "when user exists by uid/provider" do
      let!(:user) { User.create!(email: 'existing@example.com', name: 'Existing', uid: '123', provider: 'google_oauth2', role: 'admin') }

      before do
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
          provider: 'google_oauth2',
          uid: '123',
          info: { email: 'existing@example.com', name: 'Existing User' }
        )
      end

      after { OmniAuth.config.test_mode = false }

      it "logs in and redirects to root" do
        post "/auth/google_oauth2/callback", env: { "omniauth.auth" => OmniAuth.config.mock_auth[:google_oauth2] }
        expect(response).to redirect_to(root_path)
      end
    end

    context "when user exists by email but not uid" do
      let!(:user) { User.create!(email: 'match@example.com', role: 'editor') }

      before do
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
          provider: 'google_oauth2',
          uid: '999',
          info: { email: 'match@example.com', name: 'Match User' }
        )
      end

      after { OmniAuth.config.test_mode = false }

      it "links the account and logs in" do
        post "/auth/google_oauth2/callback", env: { "omniauth.auth" => OmniAuth.config.mock_auth[:google_oauth2] }
        user.reload
        expect(user.uid).to eq('999')
        expect(response).to redirect_to(root_path)
      end
    end

    context "when user is new" do
      before do
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
          provider: 'google_oauth2',
          uid: '555',
          info: { email: 'brand_new@example.com', name: 'New Person' }
        )
      end

      after { OmniAuth.config.test_mode = false }

      it "creates a new unauthorized user and redirects to unauthorized" do
        expect {
          post "/auth/google_oauth2/callback", env: { "omniauth.auth" => OmniAuth.config.mock_auth[:google_oauth2] }
        }.to change(User, :count).by(1)
        expect(User.last.role).to eq('unauthorized')
        expect(response).to redirect_to(unauthorized_path)
      end
    end
  end

  describe "DELETE /logout" do
    let!(:user) { User.create!(email: 'user@example.com', role: 'admin') }

    before { login_as(user) }

    it "logs out and redirects to login" do
      delete logout_path
      expect(response).to redirect_to(login_path)
    end
  end

  describe "GET /auth/failure" do
    it "redirects to login with alert" do
      get "/auth/failure", params: { message: 'invalid' }
      expect(response).to redirect_to(login_path)
    end
  end

  describe "GET /unauthorized" do
    context "when logged in as unauthorized user" do
      let!(:user) { User.create!(email: 'unauth@example.com', role: 'unauthorized') }

      before { login_as(user) }

      it "returns a successful response" do
        get unauthorized_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "when not logged in" do
      it "redirects to login" do
        get unauthorized_path
        expect(response).to redirect_to(login_path)
      end
    end
  end
end
