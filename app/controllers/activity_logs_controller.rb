class ActivityLogsController < ClubDashboardController
  # Organizers (admin + editor) may view; unauthorized users are blocked by ApplicationController.

  def index
    @filters = filter_params

    if invalid_date_range?
      flash.now[:alert] = "End date must be on or after start date."
      @filters_active = true
      @activity_logs = ActivityLog.none
      return
    end

    @filters_active = ActivityLog.filters_active?(@filters)
    @activity_logs = ActivityLog.filter(@filters)
  end

  private

  def filter_params
    params.permit(:content_type, :date_range, :start_date, :end_date).to_h.symbolize_keys
  end

  def invalid_date_range?
    return false unless @filters[:date_range] == "custom"

    start_on = Date.iso8601(@filters[:start_date]) rescue nil
    end_on   = Date.iso8601(@filters[:end_date])   rescue nil

    start_on.present? && end_on.present? && end_on < start_on
  end
end
