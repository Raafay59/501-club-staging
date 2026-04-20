require "rails_helper"

RSpec.describe "Registered attendees", type: :request do
  let!(:admin) { User.create!(email: "mgr@example.com", role: "admin") }

  let!(:ideathon) do
    Ideathon.create!(
      year: 2025,
      theme: "Tech",
      is_active: true,
      start_date: Date.new(2025, 2, 1),
      end_date: Date.new(2025, 2, 2)
    )
  end

  let!(:team) { Team.create!(ideathon_year: ideathon, team_name: "Team A", unassigned: false) }

  let(:valid_fields) do
    {
      attendee_name: "Pat Example",
      attendee_phone: "9795551234",
      attendee_email: "pat@tamu.edu",
      attendee_major: "CS",
      attendee_class: "U2"
    }
  end

  describe "public registration flow" do
    it "GET /registered_attendees/new renders" do
      get new_registered_attendee_path
      expect(response).to have_http_status(:ok)
    end

    it "POST /registered_attendees creates via unassigned team path" do
      expect {
        post registered_attendees_path, params: {
          registered_attendee: valid_fields,
          team_choice: ""
        }
      }.to change(RegisteredAttendee, :count).by(1)

      expect(response).to redirect_to(success_registered_attendees_path)
    end

    it "POST /registered_attendees with JSON returns created" do
      post registered_attendees_path,
        params: { registered_attendee: valid_fields, team_choice: "" },
        headers: { "Accept" => "application/json" }

      expect(response).to have_http_status(:created)
    end

    it "POST /registered_attendees with invalid data renders 422" do
      post registered_attendees_path, params: {
        registered_attendee: valid_fields.merge(attendee_email: "bad@gmail.com"),
        team_choice: ""
      }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "GET /registered_attendees/:id shows confirmation" do
      attendee = RegisteredAttendee.create!(
        ideathon_year: ideathon,
        team: team,
        **valid_fields
      )
      get registered_attendee_path(attendee)
      expect(response).to have_http_status(:ok)
    end

    it "GET /registered_attendees/success renders" do
      get success_registered_attendees_path
      expect(response).to have_http_status(:ok)
    end

    it "GET /registered_attendees/teams_for_year returns [] when year_id blank" do
      get teams_for_year_registered_attendees_path, params: { year_id: "" }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq([])
    end

    it "GET /registered_attendees/teams_for_year returns teams as JSON" do
      get teams_for_year_registered_attendees_path, params: { year_id: ideathon.id }
      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data).to be_an(Array)
      expect(data.first).to include("id" => team.id, "name" => "Team A")
    end

    it "POST with team_choice existing but no team id shows an error" do
      post registered_attendees_path, params: {
        registered_attendee: valid_fields.merge(attendee_email: "noexist@tamu.edu"),
        team_choice: "existing",
        existing_team_id: ""
      }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "POST with new team name creates the team and attendee" do
      expect {
        post registered_attendees_path, params: {
          registered_attendee: valid_fields.merge(attendee_email: "newteam@tamu.edu"),
          team_choice: "new",
          new_team_name: "Brand New Squad"
        }
      }.to change(Team, :count).by(1).and change(RegisteredAttendee, :count).by(1)
      expect(response).to redirect_to(success_registered_attendees_path)
    end

    it "POST errors when new team name is blank" do
      post registered_attendees_path, params: {
        registered_attendee: valid_fields.merge(attendee_email: "blanknew@tamu.edu"),
        team_choice: "new",
        new_team_name: "   "
      }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "POST shows a friendly error when the new team name is taken" do
      Team.create!(ideathon_year: ideathon, team_name: "Taken", unassigned: false)
      post registered_attendees_path, params: {
        registered_attendee: valid_fields.merge(attendee_email: "dupteam@tamu.edu"),
        team_choice: "new",
        new_team_name: "Taken"
      }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("already exists")
    end

    it "POST shows a friendly error when concurrent insert hits DB uniqueness" do
      allow_any_instance_of(Team).to receive(:save).and_raise(ActiveRecord::RecordNotUnique)

      post registered_attendees_path, params: {
        registered_attendee: valid_fields.merge(attendee_email: "race@tamu.edu"),
        team_choice: "new",
        new_team_name: "Concurrent Team"
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("already exists")
    end

    it "POST rejects joining a team that already has four members" do
      full = Team.create!(ideathon_year: ideathon, team_name: "Full", unassigned: false)
      4.times do |i|
        RegisteredAttendee.create!(
          ideathon_year: ideathon,
          team: full,
          attendee_name: "Member#{i}",
          attendee_phone: format("9795551%03d", i),
          attendee_email: "m#{i}@tamu.edu",
          attendee_major: "CS",
          attendee_class: "U2"
        )
      end
      post registered_attendees_path, params: {
        registered_attendee: valid_fields.merge(attendee_email: "fifth@tamu.edu"),
        team_choice: "existing",
        existing_team_id: full.id.to_s
      }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "POST rejects a team id from a different year" do
      other = Ideathon.create!(
        year: 2024,
        theme: "Old",
        is_active: false,
        start_date: Date.new(2024, 2, 1),
        end_date: Date.new(2024, 2, 2)
      )
      other_team = Team.create!(ideathon_year: other, team_name: "Other", unassigned: false)
      post registered_attendees_path, params: {
        registered_attendee: valid_fields.merge(attendee_email: "wrongyr@tamu.edu"),
        team_choice: "existing",
        existing_team_id: other_team.id.to_s
      }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "organizer tools" do
    before { login_as(admin) }

    it "GET /registered_attendees lists attendees" do
      RegisteredAttendee.create!(
        ideathon_year: ideathon,
        team: team,
        **valid_fields
      )
      get registered_attendees_path
      expect(response).to have_http_status(:ok)
    end

    it "GET /registered_attendees/:id/edit renders" do
      attendee = RegisteredAttendee.create!(
        ideathon_year: ideathon,
        team: team,
        **valid_fields
      )
      get edit_registered_attendee_path(attendee)
      expect(response).to have_http_status(:ok)
    end

    it "PATCH /registered_attendees/:id updates and redirects to manager" do
      attendee = RegisteredAttendee.create!(
        ideathon_year: ideathon,
        team: team,
        **valid_fields
      )
      patch registered_attendee_path(attendee), params: {
        registered_attendee: { attendee_name: "New Name" },
        team_choice: "existing",
        existing_team_id: team.id.to_s
      }
      expect(response).to redirect_to(manager_index_path)
      expect(attendee.reload.attendee_name).to eq("New Name")
    end

    it "PATCH /registered_attendees/:id as JSON returns 200" do
      attendee = RegisteredAttendee.create!(
        ideathon_year: ideathon,
        team: team,
        **valid_fields
      )
      patch registered_attendee_path(attendee, format: :json), params: {
        registered_attendee: { attendee_name: "Json Name" },
        team_choice: "existing",
        existing_team_id: team.id.to_s
      }
      expect(response).to have_http_status(:ok)
      expect(attendee.reload.attendee_name).to eq("Json Name")
    end

    it "PATCH /registered_attendees/:id with invalid data returns 422" do
      attendee = RegisteredAttendee.create!(
        ideathon_year: ideathon,
        team: team,
        **valid_fields
      )
      patch registered_attendee_path(attendee), params: {
        registered_attendee: { attendee_email: "bad@gmail.com" },
        team_choice: "existing",
        existing_team_id: team.id.to_s
      }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "DELETE /registered_attendees/:id removes the record" do
      attendee = RegisteredAttendee.create!(
        ideathon_year: ideathon,
        team: team,
        **valid_fields
      )
      expect {
        delete registered_attendee_path(attendee)
      }.to change(RegisteredAttendee, :count).by(-1)
      expect(response).to redirect_to(registered_attendees_path)
    end

    it "DELETE /registered_attendees/:id as JSON returns no content" do
      attendee = RegisteredAttendee.create!(
        ideathon_year: ideathon,
        team: team,
        attendee_name: "Del Json",
        attendee_phone: "9796667788",
        attendee_email: "deljson@tamu.edu",
        attendee_major: "CS",
        attendee_class: "U1"
      )
      delete registered_attendee_path(attendee, format: :json)
      expect(response).to have_http_status(:no_content)
    end

    it "POST from manager logs and returns to manager" do
      expect {
        post registered_attendees_path, params: {
          registered_attendee: valid_fields,
          team_choice: "existing",
          existing_team_id: team.id.to_s,
          return_to: "manager"
        }
      }.to change(RegisteredAttendee, :count).by(1)
      expect(response).to redirect_to(manager_index_path)
    end
  end
end
