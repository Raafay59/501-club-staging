##
# Base controller for the application.
# Handles authentication, session security, and public page logic.
class ApplicationController < ActionController::Base
     include ManagerActionLogging
     # Require admin authentication for all pages except public ones
     before_action :authenticate_admin!, unless: :public_page?
     before_action :require_organizer_tools!, unless: :skip_organizer_tools_auth?
     before_action :set_current_admin

     helper_method :current_user, :logged_in?, :admin?, :editor?, :organizer_tools?

     # Handle invalid authenticity token (CSRF error) by resetting session and redirecting
     rescue_from ActionController::InvalidAuthenticityToken do
          reset_session
          redirect_to new_admin_session_path, alert: "Your session expired or cookies were cleared. Please sign in again."
     end

  private
       def skip_organizer_tools_auth?
            devise_controller? || public_page?
       end

       def current_user
            current_admin
       end

       def logged_in?
            admin_signed_in?
       end

       def admin?
            logged_in? && current_admin.role_admin?
       end

       def editor?
            logged_in? && current_admin.role_editor?
       end

       def organizer_tools?
            logged_in? && current_admin.authorized?
       end

       def require_organizer_tools!
            return if organizer_tools?

            if admin_signed_in?
                 redirect_to root_path, alert: "Your account is not authorized for organizer tools."
            else
                 redirect_to new_admin_session_path, alert: "Please sign in to access organizer tools."
            end
       end

       def set_current_admin
            Current.admin = current_admin
            Current.user = current_admin
       end

       # Determines if the current page is public (no admin required)
       # Public pages: ideathon#index, registered_attendees#new/create/success/teams_for_year
       def public_page?
            return true if controller_name == "ideathon" && action_name == "index"
            if controller_name == "registered_attendees"
                 return true if %w[new create success teams_for_year].include?(action_name)
            end
            false
       end
end