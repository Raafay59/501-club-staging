class ActivityLogsController < ClubDashboardController
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

            start_on = ActivityLog.parse_filter_date(@filters[:start_date])
            end_on = ActivityLog.parse_filter_date(@filters[:end_date])
            start_on.present? && end_on.present? && end_on < start_on
       end
end
