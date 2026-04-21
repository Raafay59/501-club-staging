require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  controller(ApplicationController) do
    skip_before_action :require_organizer_tools!

    def editor_probe
      render plain: (send(:editor?) ? "true" : "false")
    end
  end

  before do
    routes.draw { get "editor_probe" => "anonymous#editor_probe" }
  end

  after do
    Rails.application.reload_routes!
  end

  it "returns true for editor accounts" do
    editor = User.create!(email: "editor-probe@example.com", role: "editor")
    session[:user_id] = editor.id

    get :editor_probe

    expect(response).to have_http_status(:ok)
    expect(response.body).to eq("true")
  end
end
