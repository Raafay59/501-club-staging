# frozen_string_literal: true

require "rails_helper"

RSpec.describe "RegisteredAttendees", type: :request do
     let(:ideathon_year) { IdeathonYear.create!(name: "2026", start_date: 1.week.from_now, end_date: 2.weeks.from_now, is_active: true) }
     let(:unassigned_team) { Team.create!(ideathon_year: ideathon_year, team_name: "Unassigned", unassigned: true) }
     let(:admin) { Admin.create!(email: "admin@tamu.edu", full_name: "Admin", uid: "123") }

     before { unassigned_team }

     describe "GET /registered_attendees/new" do
          it "returns success (public page)" do
               get new_registered_attendee_path
               expect(response).to have_http_status(:ok)
          end
     end

     describe "GET /registered_attendees/success" do
          it "returns success (public page)" do
               get success_registered_attendees_path
               expect(response).to have_http_status(:ok)
               expect(response.body).to include("YOU'RE IN")
          end
     end

     describe "GET /registered_attendees/teams_for_year" do
          it "returns empty array when year_id is blank" do
               get teams_for_year_registered_attendees_path, params: { year_id: "" }
               expect(response).to have_http_status(:ok)
               expect(JSON.parse(response.body)).to eq([])
          end

          it "returns teams for the given year" do
               get teams_for_year_registered_attendees_path, params: { year_id: ideathon_year.id }
               expect(response).to have_http_status(:ok)
               data = JSON.parse(response.body)
               expect(data).to be_an(Array)
               expect(data.size).to eq(1)
               expect(data.first["name"]).to eq("Unassigned")
               expect(data.first["id"]).to eq(unassigned_team.id)
          end

          it "returns empty list for non-active year ids" do
               other_year = IdeathonYear.create!(name: "2027", start_date: 3.weeks.from_now, end_date: 4.weeks.from_now, is_active: false)
               Team.create!(ideathon_year: other_year, team_name: "Other Team", unassigned: false)

               get teams_for_year_registered_attendees_path, params: { year_id: other_year.id }
               expect(response).to have_http_status(:ok)
               expect(JSON.parse(response.body)).to eq([])
          end
     end

     describe "POST /registered_attendees" do
          let(:valid_params) do
               {
                 registered_attendee: {
                   ideathon_year_id: ideathon_year.id,
                   attendee_name: "Jane Doe",
                   attendee_phone: "979-555-1234",
                   attendee_email: "jane@tamu.edu",
                   attendee_major: "CS",
                   attendee_class: "Senior"
                 },
                 team_choice: "unassigned"
               }
          end

          it "creates an attendee and redirects to success page" do
               post registered_attendees_path, params: valid_params
               expect(RegisteredAttendee.count).to eq(1)
               expect(response).to redirect_to(success_registered_attendees_path)
               expect(RegisteredAttendee.last.attendee_email).to eq("jane@tamu.edu")
          end

          context "with invalid params (missing required name)" do
               let(:invalid_params) do
                    {
                      registered_attendee: {
                        ideathon_year_id: ideathon_year.id,
                        attendee_name: "",
                        attendee_phone: "979-555-1234",
                        attendee_email: "jane@tamu.edu",
                        attendee_major: "CS",
                        attendee_class: "Senior"
                      },
                      team_choice: "unassigned"
                    }
               end

               it "re-renders new and does not create" do
                    expect { post registered_attendees_path, params: invalid_params }.not_to change(RegisteredAttendee, :count)
                    expect(response).to have_http_status(422)
               end
          end

          context "with team_choice existing" do
               it "creates attendee with existing team" do
                    params = {
                      registered_attendee: {
                        ideathon_year_id: ideathon_year.id,
                        attendee_name: "New Member",
                        attendee_phone: "979-555-0000",
                        attendee_email: "new@tamu.edu",
                        attendee_major: "CS",
                        attendee_class: "Freshman"
                      },
                      team_choice: "existing",
                      existing_team_id: unassigned_team.id
                    }
                    expect { post registered_attendees_path, params: params }.to change(RegisteredAttendee, :count).by(1)
                    expect(RegisteredAttendee.last.team_id).to eq(unassigned_team.id)
               end
          end

          context "with team_choice existing but invalid" do
               it "re-renders new when existing_team_id is blank" do
                    params = {
                      registered_attendee: {
                        ideathon_year_id: ideathon_year.id,
                        attendee_name: "X",
                        attendee_phone: "979-555-0000",
                        attendee_email: "x@tamu.edu",
                        attendee_major: "CS",
                        attendee_class: "Sr"
                      },
                      team_choice: "existing",
                      existing_team_id: ""
                    }
                    expect { post registered_attendees_path, params: params }.not_to change(RegisteredAttendee, :count)
                    expect(response).to have_http_status(422)
               end

               it "re-renders new when existing_team_id is for another year" do
                    other_year = IdeathonYear.create!(name: "2027", start_date: 3.weeks.from_now, end_date: 4.weeks.from_now, is_active: false)
                    other_team = Team.create!(ideathon_year: other_year, team_name: "Other", unassigned: false)
                    params = {
                      registered_attendee: {
                        ideathon_year_id: ideathon_year.id,
                        attendee_name: "X",
                        attendee_phone: "979-555-0000",
                        attendee_email: "x@tamu.edu",
                        attendee_major: "CS",
                        attendee_class: "Sr"
                      },
                      team_choice: "existing",
                      existing_team_id: other_team.id
                    }

                    post registered_attendees_path, params: params
                    expect(response).to have_http_status(422)
               end
          end

          context "with team_choice new" do
               it "creates attendee with new team" do
                    params = {
                      registered_attendee: {
                        ideathon_year_id: ideathon_year.id,
                        attendee_name: "Captain",
                        attendee_phone: "979-555-9999",
                        attendee_email: "cap@tamu.edu",
                        attendee_major: "CS",
                        attendee_class: "Senior"
                      },
                      team_choice: "new",
                      new_team_name: "New Team Name"
                    }
                    expect { post registered_attendees_path, params: params }.to change(RegisteredAttendee, :count).by(1)
                    expect(RegisteredAttendee.last.team.team_name).to eq("New Team Name")
               end

               it "re-renders new when new team name is blank" do
                    params = {
                      registered_attendee: {
                        ideathon_year_id: ideathon_year.id,
                        attendee_name: "Captain",
                        attendee_phone: "979-555-9999",
                        attendee_email: "cap@tamu.edu",
                        attendee_major: "CS",
                        attendee_class: "Senior"
                      },
                      team_choice: "new",
                      new_team_name: "   "
                    }
                    expect { post registered_attendees_path, params: params }.not_to change(RegisteredAttendee, :count)
                    expect(response).to have_http_status(422)
               end
          end

          context "when team is full" do
               it "re-renders new and does not create attendee" do
                    full_team = Team.create!(ideathon_year: ideathon_year, team_name: "Full Team", unassigned: false)
                    4.times do |idx|
                         RegisteredAttendee.create!(
                           ideathon_year: ideathon_year,
                           team: full_team,
                           attendee_name: "Member #{idx}",
                           attendee_phone: "979-555-12#{format('%02d', idx)}",
                           attendee_email: "member#{idx}@tamu.edu",
                           attendee_major: "CS",
                           attendee_class: "Senior"
                         )
                    end

                    params = {
                      registered_attendee: {
                        ideathon_year_id: ideathon_year.id,
                        attendee_name: "Overflow",
                        attendee_phone: "979-555-8888",
                        attendee_email: "overflow@tamu.edu",
                        attendee_major: "CS",
                        attendee_class: "Senior"
                      },
                      team_choice: "existing",
                      existing_team_id: full_team.id
                    }

                    expect { post registered_attendees_path, params: params }.not_to change(RegisteredAttendee, :count)
                    expect(response).to have_http_status(422)
               end
          end
     end

     describe "GET /registered_attendees (index)" do
          it "redirects to sign-in when not authenticated" do
               get registered_attendees_path
               expect(response).to redirect_to(new_admin_session_path)
          end

          context "when signed in as admin" do
               before { sign_in admin, scope: :admin }

               it "returns success" do
                    get registered_attendees_path
                    expect(response).to have_http_status(:ok)
               end
          end
     end

     describe "GET /registered_attendees/:id (show)" do
          let(:attendee) do
               RegisteredAttendee.create!(
                 ideathon_year: ideathon_year,
                 team: unassigned_team,
                 attendee_name: "Jane",
                 attendee_phone: "979-555-1234",
                 attendee_email: "jane@tamu.edu",
                 attendee_major: "CS",
                 attendee_class: "Senior"
               )
          end

          it "redirects guests to sign-in" do
               get registered_attendee_path(attendee)
               expect(response).to redirect_to(new_admin_session_path)
          end

          it "returns success for signed-in admins" do
               sign_in admin, scope: :admin
               get registered_attendee_path(attendee)
               expect(response).to have_http_status(:ok)
          end
     end

     describe "when no ideathon year exists" do
          before do
               Team.delete_all
               RegisteredAttendee.delete_all
               IdeathonYear.delete_all
          end

          it "shows registration unavailable on new" do
               get new_registered_attendee_path
               expect(response).to redirect_to(root_path)
               expect(flash[:alert]).to match(/registration is currently unavailable/i)
          end

          it "blocks create and does not persist attendee" do
               expect do
                    post registered_attendees_path, params: {
                      registered_attendee: {
                        attendee_name: "Jane Doe",
                        attendee_phone: "979-555-1234",
                        attendee_email: "jane@tamu.edu",
                        attendee_major: "CS",
                        attendee_class: "Senior"
                      }
                    }
               end.not_to change(RegisteredAttendee, :count)

               expect(response).to redirect_to(root_path)
          end
     end

     describe "edit, update, destroy (admin only)" do
          let(:attendee) do
               RegisteredAttendee.create!(
                 ideathon_year: ideathon_year,
                 team: unassigned_team,
                 attendee_name: "Jane",
                 attendee_phone: "979-555-1234",
                 attendee_email: "jane@tamu.edu",
                 attendee_major: "CS",
                 attendee_class: "Senior"
               )
          end

          it "edit redirects to sign-in when not authenticated" do
               get edit_registered_attendee_path(attendee)
               expect(response).to redirect_to(new_admin_session_path)
          end

          it "update redirects to sign-in when not authenticated" do
               patch registered_attendee_path(attendee), params: { registered_attendee: { attendee_name: "Updated" } }
               expect(response).to redirect_to(new_admin_session_path)
          end

          it "destroy redirects to sign-in when not authenticated" do
               delete registered_attendee_path(attendee)
               expect(response).to redirect_to(new_admin_session_path)
          end

          context "when signed in as admin" do
               before { sign_in admin, scope: :admin }

               it "edit returns success" do
                    get edit_registered_attendee_path(attendee)
                    expect(response).to have_http_status(:ok)
               end

               it "update succeeds and logs attendee update" do
                    patch registered_attendee_path(attendee), params: {
                      registered_attendee: {
                        ideathon_year_id: ideathon_year.id,
                        attendee_name: "Jane Updated",
                        attendee_phone: attendee.attendee_phone,
                        attendee_email: attendee.attendee_email,
                        attendee_major: attendee.attendee_major,
                        attendee_class: attendee.attendee_class
                      },
                      team_choice: "unassigned"
                    }
                    expect(response).to redirect_to(manager_index_path)
                    expect(attendee.reload.attendee_name).to eq("Jane Updated")
                    expect(ManagerActionLog.last&.action).to eq("attendee.updated")
               end

               it "destroy deletes, logs action, and redirects to index" do
                    delete registered_attendee_path(attendee)
                    expect(response).to redirect_to(registered_attendees_path)
                    expect(RegisteredAttendee.find_by(id: attendee.id)).to be_nil
                    expect(ManagerActionLog.last&.action).to eq("attendee.deleted")
               end

               it "update with invalid params re-renders edit" do
                    patch registered_attendee_path(attendee), params: {
                      registered_attendee: {
                        ideathon_year_id: ideathon_year.id,
                        attendee_name: "",
                        attendee_phone: attendee.attendee_phone,
                        attendee_email: attendee.attendee_email,
                        attendee_major: attendee.attendee_major,
                        attendee_class: attendee.attendee_class
                      },
                      team_choice: "unassigned"
                    }
                    expect(response).to have_http_status(422)
               end
          end
     end
end
