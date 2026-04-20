require "csv"

##
# Controller for admin management of registered attendees and teams.
# Provides dashboard, deletion, and CSV export for participants and teams.
class ManagerController < ApplicationController
     # Use the ideathon layout for all actions
     layout "ideathon"

     # GET /manager
     # Dashboard: list attendees, teams, and events for the active year
     def index
          @sort = sort_param
          @active_year = active_year
          @registered_attendees = base_scope(@active_year)
          @teams_count = teams_count_for(@active_year)
          @events = events_for(@active_year)
          @action_logs = ManagerActionLog.includes(:user).recent_first.limit(200)
     end

     # DELETE /manager/:id
     # Remove a registered attendee (admin only)
     def destroy
          @registered_attendee = RegisteredAttendee.find(params[:id])
          @registered_attendee.destroy

          log_manager_action(
               action: "attendee.deleted",
               record: @registered_attendee,
               metadata: { record_name: @registered_attendee.attendee_name, attendee_email: @registered_attendee.attendee_email }
          )

          respond_to do |format|
               format.turbo_stream do
                    @action_logs = ManagerActionLog.includes(:user).recent_first.limit(200)
                    render turbo_stream: [
                         turbo_stream.remove("registered_attendee_#{@registered_attendee.id}"),
                         turbo_stream.replace("action_logs", partial: "manager/action_logs", locals: { action_logs: @action_logs })
                    ]
               end
               format.html { redirect_to manager_index_path, notice: "Attendee removed." }
          end
     end

     # GET /manager/export_participants
     # Export all participants as a CSV file
     def export_participants
          attendees = attendee_scope_for_exports

          log_manager_action(
               action: "export.participants_csv",
               metadata: { export: "participants_csv", query: params[:query].to_s, sort: params[:sort].to_s, count: attendees.count }
          )

          csv = CSV.generate(headers: true) do |rows|
               rows << [ "Name", "Email", "Phone", "Major", "Class", "Team", "Year" ]
               attendees.find_each do |a|
                    rows << [
                         a.attendee_name,
                         a.attendee_email,
                         a.attendee_phone,
                         a.attendee_major,
                         a.attendee_class,
                         a.team&.team_name,
                         a.ideathon_year&.name
                    ]
               end
          end

          send_data csv, filename: "participants-#{Time.zone.today}.csv", type: "text/csv; charset=utf-8"
     end

     # GET /manager/export_teams
     # Export all teams and their members as a CSV file
     def export_teams
          attendees = attendee_scope_for_exports
          grouped = attendees.group_by { |a| a.team&.team_name || "Unassigned" }

          log_manager_action(
               action: "export.teams_csv",
               metadata: { export: "teams_csv", query: params[:query].to_s, sort: params[:sort].to_s, count: attendees.count }
          )

          csv = CSV.generate(headers: true) do |rows|
               rows << [ "Team", "Year", "Member Name", "Email", "Major", "Class" ]
               grouped.each do |team_name, members|
                    members.each do |m|
                         rows << [
                              team_name,
                              m.ideathon_year&.name,
                              m.attendee_name,
                              m.attendee_email,
                              m.attendee_major,
                              m.attendee_class
                         ]
                    end
               end
          end

          send_data csv, filename: "teams-#{Time.zone.today}.csv", type: "text/csv; charset=utf-8"
     end

     # GET /manager/view_pdf
     # Serves the Heroku documentation PDF for download or inline viewing
     def view_pdf
          pdf_path = Rails.root.join("public", "heroku_documentation.pdf")
          if File.exist?(pdf_path)
               send_file pdf_path, filename: "heroku_documentation.pdf", type: "application/pdf", disposition: "inline"
          else
               redirect_to manager_index_path, alert: "Heroku documentation PDF not found."
          end
     end

  private

     def active_year
          return @active_year if instance_variable_defined?(:@active_year)

          @active_year = ActiveIdeathonYear.call
     end

     def sort_param
          params[:sort] == "name" ? "name" : "team"
     end

     def attendee_scope_for_exports
          base_scope(active_year).includes(:team, :ideathon_year)
     end

     def teams_count_for(year)
          return 0 unless year

          Team.where(ideathon_year: year, unassigned: false).count
     end

     def events_for(year)
          return IdeathonEvent.none unless year

          IdeathonEvent.where(ideathon_year: year).order(event_date: :asc, event_time: :asc)
     end

     # Returns the attendee scope for dashboard and exports, filtered and sorted
     def base_scope(year)
          return RegisteredAttendee.none unless year

          scope = RegisteredAttendee.where(ideathon_year: year)
          scope = scope.search_by_name_or_team(params[:query]) if params[:query].present?
          scope = scope.sorted_by_team if sort_param == "team"
          scope
     end
end
