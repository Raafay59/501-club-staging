require "rails_helper"

RSpec.describe "Manager dashboard", type: :request do
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
  let!(:team) { Team.create!(ideathon_year: ideathon, team_name: "Squad", unassigned: false) }
  let!(:other_ideathon) do
    Ideathon.create!(
      year: 2024,
      theme: "Old",
      is_active: false,
      start_date: Date.new(2024, 2, 1),
      end_date: Date.new(2024, 2, 2)
    )
  end
  let!(:other_team) { Team.create!(ideathon_year: other_ideathon, team_name: "Old Squad", unassigned: false) }

  before { login_as(admin) }

  describe "GET /manager" do
    it "returns success" do
      get manager_index_path
      expect(response).to have_http_status(:ok)
    end

    it "accepts sort and query params" do
      RegisteredAttendee.create!(
        ideathon_year: ideathon,
        team: team,
        attendee_name: "Alex",
        attendee_phone: "9791112233",
        attendee_email: "alex@tamu.edu",
        attendee_major: "CS",
        attendee_class: "U1"
      )
      get manager_index_path, params: { sort: "name", query: "Alex" }
      expect(response).to have_http_status(:ok)
    end

    it "shows only attendees in the active year" do
      RegisteredAttendee.create!(
        ideathon_year: ideathon,
        team: team,
        attendee_name: "Current Year",
        attendee_phone: "9790001111",
        attendee_email: "current@tamu.edu",
        attendee_major: "CS",
        attendee_class: "U2"
      )
      RegisteredAttendee.create!(
        ideathon_year: other_ideathon,
        team: other_team,
        attendee_name: "Old Year",
        attendee_phone: "9790002222",
        attendee_email: "old@tamu.edu",
        attendee_major: "CS",
        attendee_class: "U2"
      )

      get manager_index_path

      expect(response.body).to include("Current Year")
      expect(response.body).not_to include("Old Year")
    end
  end

  describe "DELETE /manager/:id" do
    it "removes attendee (HTML)" do
      attendee = RegisteredAttendee.create!(
        ideathon_year: ideathon,
        team: team,
        attendee_name: "Bob",
        attendee_phone: "9792223344",
        attendee_email: "bob@tamu.edu",
        attendee_major: "EE",
        attendee_class: "U3"
      )
      expect {
        delete manager_path(attendee)
      }.to change(RegisteredAttendee, :count).by(-1)
      expect(response).to redirect_to(manager_index_path)
    end

    it "returns turbo_stream when requested" do
      attendee = RegisteredAttendee.create!(
        ideathon_year: ideathon,
        team: team,
        attendee_name: "Cara",
        attendee_phone: "9793334455",
        attendee_email: "cara@tamu.edu",
        attendee_major: "MEEN",
        attendee_class: "U4"
      )
      delete manager_path(attendee), headers: { "Accept" => "text/vnd.turbo-stream.html" }
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq(Mime[:turbo_stream])
    end
  end

  describe "exports" do
    before do
      RegisteredAttendee.create!(
        ideathon_year: ideathon,
        team: team,
        attendee_name: "Dan",
        attendee_phone: "9794445566",
        attendee_email: "dan@tamu.edu",
        attendee_major: "CSCE",
        attendee_class: "U2"
      )
    end

    it "GET /manager/export_participants returns CSV" do
      get export_participants_manager_index_path
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/csv")
      expect(response.body).to include("Dan")
    end

    it "GET /manager/export_teams returns CSV" do
      get export_teams_manager_index_path
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/csv")
    end

    it "exports only attendees in the active year" do
      RegisteredAttendee.create!(
        ideathon_year: other_ideathon,
        team: other_team,
        attendee_name: "Archived",
        attendee_phone: "9797778899",
        attendee_email: "archived@tamu.edu",
        attendee_major: "ISTM",
        attendee_class: "U3"
      )

      get export_participants_manager_index_path

      expect(response.body).to include("Dan")
      expect(response.body).not_to include("Archived")
    end
  end

  describe "GET /manager/view_pdf" do
    it "sends file when PDF exists" do
      pdf = Rails.root.join("public", "heroku_documentation.pdf")
      FileUtils.mkdir_p(pdf.dirname)
      File.write(pdf, "%PDF-1.4 test")

      get view_pdf_manager_index_path

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("application/pdf")
    ensure
      FileUtils.rm_f(pdf)
    end

    it "redirects when PDF missing" do
      pdf = Rails.root.join("public", "heroku_documentation.pdf")
      FileUtils.rm_f(pdf)

      get view_pdf_manager_index_path

      expect(response).to redirect_to(manager_index_path)
      expect(flash[:alert]).to include("not found")
    end
  end
end
