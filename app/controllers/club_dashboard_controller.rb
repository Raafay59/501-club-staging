# frozen_string_literal: true

# Base controller for the 501 Club organizer dashboard (Google OAuth + role checks).
class ClubDashboardController < ApplicationController
  skip_before_action :require_organizer_tools!

  around_action :set_current_user_context
  before_action :require_login
  before_action :require_authorized

  private

  def set_current_user_context
    Current.user = current_user
    yield
  ensure
    Current.reset
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

  def require_login
    unless logged_in?
      redirect_to login_path, alert: "You must be logged in."
    end
  end

  def require_authorized
    return unless logged_in?
    if current_user.unauthorized?
      redirect_to unauthorized_path
    end
  end

  def require_admin
    unless admin?
      redirect_to ideathons_path, alert: "Only 501 Club admins can perform this action."
    end
  end
end
