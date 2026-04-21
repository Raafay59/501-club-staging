##
# Controller for managing Ideathon events (admin only).
# Handles creation, editing, updating, and deletion of events for the active year.
class IdeathonEventsController < ApplicationController
     # Use the ideathon layout for all actions
     layout "ideathon"
     before_action :require_admin_for_events!
     # Load the event for actions that require an existing record
     before_action :set_ideathon_event, only: %i[ edit update destroy ]

     # GET /ideathon_events/new
     # Show form to create a new event
     def new
          @ideathon_event = IdeathonEvent.new
     end

     # GET /ideathon_events/:id/edit
     # Show form to edit an existing event
     def edit; end

     # POST /ideathon_events
     # Create a new event for the active year
     def create
          @ideathon_event = IdeathonEvent.new(event_params)
          @ideathon_event.ideathon_year = active_year

          if @ideathon_event.ideathon_year.blank?
               @ideathon_event.errors.add(:ideathon_year, "is required")
               render :new, status: :unprocessable_entity
               return
          end

          if @ideathon_event.save
               log_manager_action(
                    action: "event.created",
                    record: @ideathon_event,
                    metadata: {
                         record_name: @ideathon_event.event_name,
                         event_name: @ideathon_event.event_name,
                         event_date: @ideathon_event.event_date,
                         event_time: @ideathon_event.event_time
                    }
               )
               redirect_to manager_index_path(tab: "events"), notice: "Event created."
          else
               render :new, status: :unprocessable_entity
          end
     end

     # PATCH/PUT /ideathon_events/:id
     # Update an existing event
     def update
          if @ideathon_event.update(event_params)
               changes = @ideathon_event.saved_changes.slice("event_name", "event_description", "event_date", "event_time")
               log_manager_action(
                    action: "event.updated",
                    record: @ideathon_event,
                    metadata: {
                         record_name: @ideathon_event.event_name,
                         changes: changes
                    }
               )
               redirect_to manager_index_path(tab: "events"), notice: "Event updated."
          else
               render :edit, status: :unprocessable_entity
          end
     end

     # DELETE /ideathon_events/:id
     # Delete an event (admin only)
     def destroy
          @ideathon_event.destroy
          log_manager_action(
               action: "event.deleted",
               record: @ideathon_event,
               metadata: {
                    record_name: @ideathon_event.event_name,
                    event_name: @ideathon_event.event_name,
                    event_date: @ideathon_event.event_date,
                    event_time: @ideathon_event.event_time
               }
          )
          respond_to do |format|
               format.turbo_stream do
                    action_logs = ManagerActionLog.includes(:user).recent_first.limit(200)
                    render turbo_stream: [
                         turbo_stream.remove("ideathon_event_#{@ideathon_event.id}"),
                         turbo_stream.replace("action_logs", partial: "manager/action_logs", locals: { action_logs: action_logs })
                    ]
               end
               format.html { redirect_to manager_index_path(tab: "events"), notice: "Event deleted." }
          end
     end

  private

     def active_year
          ActiveIdeathonYear.call
     end

     # Finds the event for actions that require an existing record
     def set_ideathon_event
          @ideathon_event = IdeathonEvent.where(ideathon_year: active_year).find(params[:id])
     rescue ActiveRecord::RecordNotFound
          redirect_to manager_index_path(tab: "events"), alert: "Event not found for the active year."
     end

     def require_admin_for_events!
          return if admin?

          redirect_to manager_index_path(tab: "events"), alert: "Only 501 Club admins can perform this action."
     end

     # Strong parameters: only allow trusted fields from the form
     def event_params
          params.require(:ideathon_event).permit(:event_name, :event_description, :event_date, :event_time)
     end
end
