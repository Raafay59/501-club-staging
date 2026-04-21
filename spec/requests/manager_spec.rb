# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Manager", type: :request do
     let(:ideathon_year) { IdeathonYear.create!(name: "2026", start_date: 1.week.from_now, end_date: 2.weeks.from_now, is_active: true) }
     let(:team) { Team.create!(ideathon_year: ideathon_year, team_name: "Team A", unassigned: false) }
     let(:team_b) { Team.create!(ideathon_year: ideathon_year, team_name: "Team B", unassigned: false) }
     let(:admin) { Admin.create!(email: "admin@tamu.edu", full_name: "Admin", uid: "123") }
     let!(:attendee) do
          RegisteredAttendee.create!(
            ideathon_year: ideathon_year,
            team: team,
            attendee_name: "Jane Doe",
            attendee_phone: "979-555-1234",
            attendee_email: "jane@tamu.edu",
            attendee_major: "CS",
            attendee_class: "Senior"
          )
     end
     let!(:attendee_b) do
          RegisteredAttendee.create!(
            ideathon_year: ideathon_year,
            team: team_b,
            attendee_name: "Aaron Zee",
            attendee_phone: "979-555-5678",
            attendee_email: "aaron@tamu.edu",
            attendee_major: "EE",
            attendee_class: "Junior"
          )
     end

     describe "GET /manager" do
          context "when not authenticated" do
               it "redirects to sign-in" do
                    get manager_index_path
                    expect(response).to redirect_to(new_admin_session_path)
               end
          end

          context "when signed in as admin" do
               before { sign_in admin, scope: :admin }

               it "returns success" do
                    get manager_index_path
                    expect(response).to have_http_status(:ok)
               end

               it "sorts by team by default" do
                    get manager_index_path
                    expect(response).to have_http_status(:ok)
                    expect(response.body.index("Team A")).to be < response.body.index("Team B")
               end

               it "sorts by name when sort=name" do
                    get manager_index_path, params: { sort: "name" }
                    expect(response).to have_http_status(:ok)
                    expect(response.body.index("Aaron Zee")).to be < response.body.index("Jane Doe")
               end

               it "filters by query when query present" do
                    get manager_index_path, params: { query: "Jane" }
                    expect(response).to have_http_status(:ok)
               end
          end
     end

     describe "DELETE /manager/:id" do
          before { sign_in admin, scope: :admin }

          it "removes attendee, logs action, and redirects to manager index" do
               expect { delete manager_path(attendee) }
                 .to change(RegisteredAttendee, :count).by(-1)
                 .and change(ManagerActionLog, :count).by(1)
               expect(response).to redirect_to(manager_index_path)
               expect(ManagerActionLog.last.action).to eq("attendee.deleted")
               follow_redirect!
               expect(response).to have_http_status(:ok)
          end

          it "returns turbo-stream response when requested" do
               delete manager_path(attendee), headers: { "Accept" => "text/vnd.turbo-stream.html" }
               expect(response).to have_http_status(:ok)
               expect(response.media_type).to eq("text/vnd.turbo-stream.html")
          end
     end

     describe "GET /manager/export_participants" do
          before { sign_in admin, scope: :admin }

          it "returns CSV for participants and logs export" do
               get export_participants_manager_index_path(format: :csv)
               expect(response).to have_http_status(:ok)
               expect(response.media_type).to include("text/csv")
               expect(response.body).to include("Name,Email,Phone,Major,Class,Team,Year")
               expect(response.body).to include("Jane Doe")
               expect(ManagerActionLog.last&.action).to eq("export.participants_csv")
          end

          it "still returns CSV when action logging raises" do
               allow(ManagerActionLog).to receive(:create!).and_raise(StandardError.new("log failure"))

               get export_participants_manager_index_path(format: :csv)

               expect(response).to have_http_status(:ok)
               expect(response.media_type).to include("text/csv")
          end
     end

     describe "GET /manager/export_teams" do
          before { sign_in admin, scope: :admin }

          it "returns CSV for teams and logs export" do
               get export_teams_manager_index_path(format: :csv)
               expect(response).to have_http_status(:ok)
               expect(response.media_type).to include("text/csv")
               expect(response.body).to include("Team,Year,Member Name,Email,Major,Class")
               expect(response.body).to include("Team A")
               expect(response.body).to include("Jane Doe")
               expect(ManagerActionLog.last&.action).to eq("export.teams_csv")
          end
     end

     describe "GET /manager/view_pdf" do
          before { sign_in admin, scope: :admin }

          it "redirects with alert when file is missing" do
               allow(File).to receive(:exist?).and_call_original
               allow(File).to receive(:exist?).with(Rails.root.join("public", "heroku_documentation.pdf")).and_return(false)

               get view_pdf_manager_index_path
               expect(response).to redirect_to(manager_index_path)
               expect(flash[:alert]).to eq("Heroku documentation PDF not found.")
          end
     end
end
