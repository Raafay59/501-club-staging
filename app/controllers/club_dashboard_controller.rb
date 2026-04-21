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
end
