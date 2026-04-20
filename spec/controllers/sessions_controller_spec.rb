require "rails_helper"

RSpec.describe SessionsController, type: :controller do
  describe "POST #create" do
    before do
      routes.draw do
        get "login" => "sessions#new", as: :login
        post "auth/google_oauth2/callback" => "sessions#create"
      end
    end

    after do
      Rails.application.reload_routes!
    end

    it "redirects to login when auth payload is missing" do
      request.env["omniauth.auth"] = nil

      post :create, params: { provider: "google_oauth2" }

      expect(response).to redirect_to(login_path)
      expect(flash[:alert]).to eq("Authentication failed.")
    end
  end
end
