require "rails_helper"

RSpec.describe "Ideathon events", type: :request do
  let!(:admin) { User.create!(email: "admin@example.com", role: "admin") }
  let!(:ideathon) do
    Ideathon.create!(
      year: 2025,
      theme: "T",
      is_active: true,
      start_date: Date.new(2025, 2, 1),
      end_date: Date.new(2025, 2, 2)
    )
  end

  before { login_as(admin) }

  describe "GET /ideathon_events/new" do
    it "renders the form" do
      get new_ideathon_event_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /ideathon_events" do
    it "creates an event for the active year" do
      expect {
        post ideathon_events_path, params: {
          ideathon_event: {
            event_name: "Opening",
            event_description: "Kickoff",
            event_date: Date.new(2025, 2, 1),
            event_time: "09:00"
          }
        }
      }.to change(IdeathonEvent, :count).by(1)

      expect(response).to redirect_to(manager_index_path(tab: "events"))
    end

    it "still creates the event when logging raises" do
      allow(ManagerActionLog).to receive(:create!).and_raise(StandardError, "log unavailable")
      expect {
        post ideathon_events_path, params: {
          ideathon_event: {
            event_name: "Backup",
            event_description: "x",
            event_date: Date.new(2025, 2, 1),
            event_time: "11:00"
          }
        }
      }.to change(IdeathonEvent, :count).by(1)
      expect(response).to redirect_to(manager_index_path(tab: "events"))
    end

    it "renders new on validation errors" do
      post ideathon_events_path, params: {
        ideathon_event: {
          event_name: "",
          event_description: "",
          event_date: nil,
          event_time: nil
        }
      }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /ideathon_events/:id" do
    let!(:event) do
      IdeathonEvent.create!(
        ideathon_year: ideathon,
        event_name: "Workshop",
        event_description: "Design",
        event_date: Date.new(2025, 2, 1),
        event_time: "10:00"
      )
    end

    it "updates the event" do
      patch ideathon_event_path(event), params: {
        ideathon_event: { event_name: "Workshop Plus" }
      }
      expect(response).to redirect_to(manager_index_path(tab: "events"))
      expect(event.reload.event_name).to eq("Workshop Plus")
    end

    it "renders edit on failure" do
      patch ideathon_event_path(event), params: {
        ideathon_event: { event_name: "" }
      }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /ideathon_events/:id" do
    def create_event!(name: "Closing")
      IdeathonEvent.create!(
        ideathon_year: ideathon,
        event_name: name,
        event_description: "Awards",
        event_date: Date.new(2025, 2, 2),
        event_time: "18:00"
      )
    end

    it "removes the event (HTML)" do
      event = create_event!
      expect {
        delete ideathon_event_path(event)
      }.to change(IdeathonEvent, :count).by(-1)
      expect(response).to redirect_to(manager_index_path(tab: "events"))
    end

    it "returns turbo_stream when requested" do
      event = create_event!(name: "Turbo Only")
      delete ideathon_event_path(event), headers: { "Accept" => "text/vnd.turbo-stream.html" }
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq(Mime[:turbo_stream])
    end
  end

  describe "GET /ideathon_events/:id/edit" do
    it "renders edit" do
      event = IdeathonEvent.create!(
        ideathon_year: ideathon,
        event_name: "Lunch",
        event_description: "Food",
        event_date: Date.new(2025, 2, 1),
        event_time: "12:00"
      )
      get edit_ideathon_event_path(event)
      expect(response).to have_http_status(:ok)
    end
  end
end
