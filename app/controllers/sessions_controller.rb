class SessionsController < ApplicationController
  skip_before_action :require_login
  skip_before_action :require_authorized

  def new
  end

  ALLOWED_EMAILS = ["ernest01@tamu.edu"]
  
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
        if ALLOWED_EMAILS.include?(auth.info.email)
          user.update(uid: auth["uid"], provider: auth["provider"], name: auth["info"]["name"], role: "admin")
        else
          user.update(uid: auth["uid"], provider: auth["provider"], name: auth["info"]["name"])
        end
      else

        role = ALLOWED_EMAILS.include?(auth["info"]["email"]) ? "admin" : "unauthorized"
        user = User.create(
          email: auth["info"]["email"],
          name: auth["info"]["name"],
          uid: auth["uid"],
          provider: auth["provider"],
          role: role
        )
      end
    end

    if user.persisted?
      session[:user_id] = user.id
      if user.unauthorized?
        redirect_to unauthorized_path
      else
        redirect_to root_path, notice: "Signed in as #{user.name}."
      end
    else
      redirect_to login_path, alert: "Unable to create account."
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: "Signed out successfully."
  end

  def failure
    redirect_to login_path, alert: "Authentication failed: #{params[:message]}"
  end

  def unauthorized
    redirect_to login_path unless logged_in?
  end
end
