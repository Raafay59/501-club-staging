##
# Controller for handling admin authentication via Google OAuth.
# Customizes Devise Omniauth callbacks for admin sign-in and error handling.
class Admins::OmniauthCallbacksController < Devise::OmniauthCallbacksController
     # Handles callback from Google OAuth2
     def google_oauth2
          unless auth.present?
               flash[:alert] = "Authentication failed. Please try again."
               redirect_to new_admin_session_path, status: :see_other
               return
          end

          admin = Admin.from_google(**from_google_params)

          if admin.present?
               sign_out_all_scopes
               flash[:success] = t "devise.omniauth_callbacks.success", kind: "Google"
               sign_in_and_redirect admin, event: :authentication
          else
               email = auth&.info&.email || "this account"
               flash[:alert] = "#{email} is not authorized as an admin."
               redirect_to new_admin_session_path, status: :see_other
          end
     end

  protected

       # Redirect to login page on Omniauth failure
       def after_omniauth_failure_path_for(_scope)
            new_admin_session_path
       end

       # After successful sign-in, redirect to manager dashboard
       def after_sign_in_path_for(resource_or_scope)
            stored_location_for(resource_or_scope) || manager_index_path
       end

  private

       # Extracts parameters from Google OAuth response
       def from_google_params
            email = auth&.info&.email
            email = auth&.dig("extra", "raw_info", "email") if email.blank?

            @from_google_params ||= {
              uid: auth.uid,
              email: email,
              full_name: auth.info.name,
              avatar_url: auth.info.image
            }
       end

       # Returns the Omniauth auth hash
       def auth
            @auth ||= request.env["omniauth.auth"]
       end
end
