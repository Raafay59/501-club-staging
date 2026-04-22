##
# Controller for customizing admin session behavior (login/logout).
# Uses the ideathon layout and customizes redirect paths.
class Admins::SessionsController < Devise::SessionsController
     # Use the ideathon layout for all session pages
     layout "ideathon"

     # Redirect to login page after sign out
     def after_sign_out_path_for(_resource_or_scope)
          new_admin_session_path
     end

     # Redirect to stored location or root after sign in
     def after_sign_in_path_for(resource_or_scope)
          stored_location_for(resource_or_scope) || root_path
     end
end
