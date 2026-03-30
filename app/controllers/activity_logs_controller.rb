class ActivityLogsController < ApplicationController
  # Organizers (admin + editor) may view; unauthorized users are blocked by ApplicationController.

  def index
    @filters = filter_params
    @filters_active = ActivityLog.filters_active?(@filters)
    @activity_logs = ActivityLog.filter(@filters)
  end

  private

  def filter_params
    params.permit(:content_type, :date_range, :start_date, :end_date).to_h.symbolize_keys
  end
end
