class UsersController < ApplicationController
  before_action :require_admin

  def index
    @users = User.order(Arel.sql("CASE role WHEN 'admin' THEN 0 WHEN 'editor' THEN 1 ELSE 2 END"), :email)
    @new_user = User.new
  end

  def create
    @new_user = User.new(email: user_params[:email], role: user_params[:role])
    if @new_user.save
      redirect_to users_path, notice: "#{@new_user.email} added as #{@new_user.role}."
    else
      @users = User.order(Arel.sql("CASE role WHEN 'admin' THEN 0 WHEN 'editor' THEN 1 ELSE 2 END"), :email)
      render :index, status: :unprocessable_entity
    end
  end

  def update
    @user = User.find(params[:id])
    new_role = user_params[:role]

    if @user == current_user && new_role != "admin"
      if User.where(role: "admin").count <= 1
        redirect_to users_path, alert: "Cannot change your role — you are the only admin."
        return
      end
    end

    if @user.update(role: new_role)
      redirect_to users_path, notice: "#{@user.email} updated to #{new_role}."
    else
      redirect_to users_path, alert: "Failed to update role."
    end
  end

  def destroy
    @user = User.find(params[:id])

    if @user == current_user
      redirect_to users_path, alert: "You cannot delete your own account. Demote yourself first if needed."
      return
    end

    if @user.destroy
      redirect_to users_path, notice: "#{@user.email} has been removed."
    else
      redirect_to users_path, alert: @user.errors.full_messages.to_sentence
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :role)
  end
end
