# frozen_string_literal: true

# Base controller for organizer dashboard modules.
class ClubDashboardController < ApplicationController
     skip_before_action :require_organizer_tools!
     before_action :require_login
     before_action :require_authorized

  private

       def require_login
            return if logged_in?

            redirect_to new_admin_session_path, alert: "You must be logged in."
       end

       def require_authorized
            return unless logged_in?
            return if organizer_tools?

            redirect_to root_path, alert: "Your account is not authorized for dashboard tools."
       end

       def require_admin
            return if admin?

            redirect_to root_path, alert: "Only admins can perform this action."
       end

       def assign_ideathon_years_for_form!
            @ideathon_years = Ideathon.where.not(year: nil).pluck(:year).sort.reverse
       end

       def redirect_after_csv_import!(result:, redirect_path:, failure_alert:, success_notice:)
            if result[:failed] > 0
                 redirect_to redirect_path, alert: failure_alert.call(result)
            else
                 redirect_to redirect_path, notice: success_notice.call(result)
            end
       end

       def normalize_optional_url_from_params!(record, root_key:, attribute:, include_flag:)
            include_url = params.dig(root_key, include_flag) != "0"
            current = record.public_send(attribute)
            record.public_send(:"#{attribute}=", include_url ? current.to_s.strip.presence : nil)
       end
end
