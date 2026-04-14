# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :require_organizer_tools!

  def new
    if logged_in? && current_user.authorized?
      redirect_to ideathons_path
    elsif logged_in?
      redirect_to unauthorized_path
    end
  end

  def create
    auth = request.env["omniauth.auth"]

    if auth.nil?
      redirect_to login_path, alert: "Authentication failed."
      return
    end

    user = User.find_by(uid: auth["uid"], provider: auth["provider"])
    if user.nil?
      user = User.find_by(email: auth["info"]["email"])
      if user
        user.update(uid: auth["uid"], provider: auth["provider"], name: auth["info"]["name"])
      else

        user = User.create(
          email: auth["info"]["email"],
          name: auth["info"]["name"],
          uid: auth["uid"],
          provider: auth["provider"],
          role: "unauthorized"
        )
      end
    end

    if user.persisted?
      session[:user_id] = user.id
      if user.unauthorized?
        redirect_to unauthorized_path
      else
        redirect_to ideathons_path, notice: "Signed in as #{user.name}."
      end
    else
      redirect_to login_path, alert: "Unable to create account."
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Signed out successfully."
  end

  def failure
    redirect_to login_path, alert: "Authentication failed: #{params[:message]}"
  end

  def unauthorized
    redirect_to login_path unless logged_in?
  end
end
