class ActivityLogsController < ApplicationController
  # Organizers (admin + editor) may view; unauthorized users are blocked by ApplicationController.

  def index
    @activity_logs = ActivityLog.includes(:user).order(created_at: :desc).limit(500)
  end
end
