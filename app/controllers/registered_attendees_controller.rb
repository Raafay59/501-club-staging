##
# Controller for managing registered attendees in the Ideathon event.
# Handles attendee registration, editing, team assignment, and related AJAX endpoints.
# Follows Rails RESTful conventions and includes custom logic for team selection.
class RegisteredAttendeesController < ApplicationController
     # Allow public access to registration and info pages
     skip_before_action :require_organizer_tools!, only: %i[new create success teams_for_year]
     # Load attendee for actions that require an existing record
     before_action :set_registered_attendee, only: %i[show edit update destroy]
     before_action :set_active_year, only: %i[new create edit update]
     # Load teams for forms where team selection is needed
     before_action :load_teams, only: %i[new create edit update]
     # Use the ideathon layout for registration-related pages
     layout "ideathon", only: %i[new create success edit update]


     # List all registered attendees (admin only)
     def index
          @registered_attendees = RegisteredAttendee.where(ideathon_year: active_year)
     end


     # Show a single registered attendee (organizer only)
     def show; end


     # Display the registration form for a new attendee
     def new
          @registered_attendee = RegisteredAttendee.new
          @registered_attendee.ideathon_year = @active_year
          load_teams
     end


     # Edit an existing attendee (admin only)
     def edit; end


     # Show registration success page
     def success; end


     # Create a new registered attendee from form input
     # Handles team assignment and validation, responds to HTML/JSON
     def create
          @registered_attendee = RegisteredAttendee.new(registered_attendee_params)
          @registered_attendee.ideathon_year = @active_year

          saved = false
          RegisteredAttendee.transaction do
               # Assign team based on form selection, enforcing team size limit
               apply_team_selection!(@registered_attendee, enforce_limit: true)
               if @registered_attendee.errors.any?
                    raise ActiveRecord::Rollback
               end

               saved = @registered_attendee.save
               raise ActiveRecord::Rollback unless saved
          end

          respond_to do |format|
               if @registered_attendee.errors.any?
                    load_teams
                    format.html { render :new, status: :unprocessable_entity }
                    format.json { render json: @registered_attendee.errors, status: :unprocessable_entity }
               elsif saved
                    if organizer_tools? && params[:return_to] == "manager"
                         log_manager_action(
                           action: "attendee.created",
                           record: @registered_attendee,
                           metadata: { record_name: @registered_attendee.attendee_name, attendee_email: @registered_attendee.attendee_email, source: "manager" }
                         )
                    end
                    format.html { redirect_to params[:return_to] == "manager" ? manager_index_path : success_registered_attendees_path, status: :see_other }
                    format.json do
                         if organizer_tools?
                              render :show, status: :created, location: @registered_attendee
                         else
                              render :show, status: :created
                         end
                    end
               else
                    load_teams
                    format.html { render :new, status: :unprocessable_entity }
                    format.json { render json: @registered_attendee.errors, status: :unprocessable_entity }
               end
          end
     end


     # Update an existing registered attendee (admin only)
     # Handles team reassignment and validation
     def update
          @registered_attendee.assign_attributes(registered_attendee_params)
          apply_team_selection!(@registered_attendee)

          respond_to do |format|
               if @registered_attendee.errors.any?
                    load_teams
                    format.html { render :edit, status: :unprocessable_entity }
                    format.json { render json: @registered_attendee.errors, status: :unprocessable_entity }
               elsif @registered_attendee.save
                    changes = @registered_attendee.saved_changes.slice(
                      "attendee_name",
                      "attendee_phone",
                      "attendee_email",
                      "attendee_major",
                      "attendee_class",
                      "team_id"
                    )
                    log_manager_action(
                      action: "attendee.updated",
                      record: @registered_attendee,
                      metadata: { record_name: @registered_attendee.attendee_name, changes: changes }
                    )
                    format.html { redirect_to manager_index_path, notice: "Attendee updated successfully.", status: :see_other }
                    format.json { render :show, status: :ok, location: @registered_attendee }
               else
                    load_teams
                    format.html { render :edit, status: :unprocessable_entity }
                    format.json { render json: @registered_attendee.errors, status: :unprocessable_entity }
               end
          end
     end


     # Delete a registered attendee (admin only)
     def destroy
          @registered_attendee.destroy!
          log_manager_action(
            action: "attendee.deleted",
            record: @registered_attendee,
            metadata: { record_name: @registered_attendee.attendee_name, attendee_email: @registered_attendee.attendee_email }
          )
          respond_to do |format|
               format.html { redirect_to registered_attendees_path, notice: "Registered attendee was successfully destroyed.", status: :see_other }
               format.json { head :no_content }
          end
     end


     # AJAX endpoint: Return teams for a given year as JSON (for dynamic form updates)
     def teams_for_year
          active = ActiveIdeathonYear.call
          unless active
               render json: []
               return
          end

          year_id = params[:year_id]
          if year_id.blank?
               render json: []
               return
          end

          if year_id.to_i != active.id
               render json: []
               return
          end

          teams = Team
            .where(ideathon_year_id: active.id)
            .left_joins(:registered_attendees)
            .group("teams.id", "teams.team_name", "teams.unassigned")
            .order(:unassigned, :team_name)
            .select("teams.id", "teams.team_name", "teams.unassigned", "COUNT(registered_attendees.id) AS member_count")

          team_list = teams.map do |team|
               {
                 id: team.id,
                 name: team.team_name,
                 member_count: team.attributes["member_count"].to_i,
                 unassigned: team.unassigned
               }
          end
          render json: team_list
     end

  private

       # Finds the registered attendee for actions that require an existing record
       def set_registered_attendee
            @registered_attendee = RegisteredAttendee.where(ideathon_year: active_year).find(params[:id])
       rescue ActiveRecord::RecordNotFound
            redirect_to manager_index_path, alert: "Attendee not found for the active year."
       end

       # Returns the currently active Ideathon year
       def active_year
            ActiveIdeathonYear.call(create_if_missing: true)
       end

       def set_active_year
            @active_year = active_year
       end

       # Loads teams for the active year, ordered for form display
       def load_teams
            @teams = Team.where(ideathon_year: @active_year).order(:unassigned, :team_name)
       end

       # Strong parameters: only allow trusted fields from the form
       # Note: :team_id is NOT trusted from the form, set in apply_team_selection!
       def registered_attendee_params
            params.require(:registered_attendee).permit(
              :ideathon_year_id,
              :attendee_name,
              :attendee_phone,
              :attendee_email,
              :attendee_major,
              :attendee_class
              # :team_id intentionally omitted
            )
       end

       # Assigns a team to the attendee based on form input.
       # Handles three cases: existing team, new team, or unassigned.
       # Adds errors to attendee if selection is invalid or team is full.
       # enforce_limit: if true, prevents assigning to a full team (max 4 members)
       #
       # Expects params:
       #   team_choice: "existing", "new", or "unassigned"
       #   existing_team_id: id of selected team (if any)
       #   new_team_name: name for new team (if any)
       def apply_team_selection!(attendee, enforce_limit: false)
            # year must be selected first
            if attendee.ideathon_year_id.blank?
                 attendee.errors.add(:ideathon_year_id, "must be selected")
                 return
            end

            team_choice = params[:team_choice].to_s
            existing_team_id = params[:existing_team_id].to_s
            new_team_name = params[:new_team_name].to_s.strip

            case team_choice
            when "existing"
                 if existing_team_id.blank?
                      attendee.errors.add(:base, "Please select an existing team.")
                      return
                 end

                 team = Team.find_by(id: existing_team_id.to_i, ideathon_year_id: attendee.ideathon_year_id)
                 if team.nil?
                      attendee.errors.add(:base, "Selected team is invalid for this year.")
                      return
                 end

                 if enforce_limit
                      team.with_lock do
                           member_count = team.registered_attendees.count
                           if member_count >= 4
                                attendee.errors.add(:base, "That team is already full (max 4 members).")
                                return
                           end
                      end
                 end

                 attendee.team_id = team.id

            when "new"
                 if new_team_name.blank?
                      attendee.errors.add(:base, "Please enter a new team name.")
                      return
                 end

                 team = Team.new(
                   ideathon_year_id: attendee.ideathon_year_id,
                   team_name: new_team_name,
                   unassigned: false
                 )

                 begin
                      unless team.save
                           team.errors.full_messages.each do |msg|
                                # Make error messages more user-friendly for the form
                                friendly_msg = msg.include?("already exists") ? "Team name \"#{new_team_name}\" already exists" : msg
                                attendee.errors.add(:base, friendly_msg)
                           end
                           return
                      end
                 rescue ActiveRecord::RecordNotUnique
                      attendee.errors.add(:base, "Team name \"#{new_team_name}\" already exists")
                      return
                 end

                 attendee.team_id = team.id

            else
                 # Default: assign to "Unassigned" team if no valid choice
                 begin
                      unassigned = Team.find_or_create_by!(ideathon_year_id: attendee.ideathon_year_id, unassigned: true) do |t|
                           t.team_name = "Unassigned"
                      end
                      attendee.team_id = unassigned.id
                 rescue => e
                      attendee.errors.add(:base, "Unable to create or find unassigned team. Please contact support.")
                      nil
                 end
            end
       end
end
