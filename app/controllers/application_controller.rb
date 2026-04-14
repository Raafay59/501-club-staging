# frozen_string_literal: true

class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  include ManagerActionLogging

  # Public-site manager tools (registration, events, CSV) require a 501 Club User with role admin or editor.
  before_action :require_organizer_tools!, unless: :skip_organizer_tools_auth?

  helper_method :current_user, :logged_in?, :admin?, :editor?, :organizer_tools?

  private

  def skip_organizer_tools_auth?
    is_a?(ClubDashboardController) ||
      is_a?(SessionsController) ||
      public_site_request?
  end

  def public_site_request?
    return true if controller_name == "ideathon" && action_name == "index"
    return true if controller_name == "registered_attendees" &&
      %w[new create show success teams_for_year].include?(action_name)

    false
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def admin?
    logged_in? && current_user.admin?
  end

  def editor?
    logged_in? && current_user.editor?
  end

  # Logged-in 501 Club organizer (admin or editor): can use dashboard and public manager tools.
  def organizer_tools?
    current_user&.authorized?
  end

  def require_organizer_tools!
    unless logged_in?
      redirect_to login_path,
        alert: "Sign in with a 501 Club organizer account (admin or editor) to continue."
      return
    end

    return if current_user.authorized?

    redirect_to unauthorized_path,
      alert: "Your account doesn’t have access to registration manager tools. Ask a 501 Club admin to grant editor or admin role."
  end
end
