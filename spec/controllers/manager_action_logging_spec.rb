require "rails_helper"

RSpec.describe ManagerActionLogging, type: :controller do
  controller(ApplicationController) do
    skip_before_action :require_organizer_tools!

    def index
      log_manager_action(action: params[:action_name])
      head :ok
    end
  end

  let(:admin) { User.create!(email: "admin-log@example.com", role: "admin") }
  let(:unauthorized) { User.create!(email: "nopriv@example.com", role: "unauthorized") }

  before do
    routes.draw { get "index" => "anonymous#index" }
  end

  it "does not log when the user is not an organizer" do
    session[:user_id] = unauthorized.id
    expect(ManagerActionLog).not_to receive(:create!)
    get :index, params: { action_name: "attendee.created" }
  end

  it "does not log when action is blank" do
    session[:user_id] = admin.id
    expect(ManagerActionLog).not_to receive(:create!)
    get :index, params: { action_name: "" }
  end

  it "swallows StandardError from create! so the request still succeeds" do
    session[:user_id] = admin.id
    allow(ManagerActionLog).to receive(:create!).and_raise(StandardError, "fail")
    expect {
      get :index, params: { action_name: "test.action" }
    }.not_to raise_error
    expect(response).to have_http_status(:ok)
  end
end
