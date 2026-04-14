class UsersController < ClubDashboardController
  before_action :require_admin

  def index
    @users = User.order(Arel.sql("CASE role WHEN 'admin' THEN 0 WHEN 'editor' THEN 1 ELSE 2 END"), :email)
    @new_user = User.new
  end

  def create
    @new_user = User.new(email: user_params[:email], role: "unauthorized")
    if @new_user.save
      @new_user.send_request_email
      redirect_to users_path, notice: "#{@new_user.email} added as #{@new_user.role}."
    else
      @users = User.order(Arel.sql("CASE role WHEN 'admin' THEN 0 WHEN 'editor' THEN 1 ELSE 2 END"), :email)
      render :index, status: :unprocessable_entity
    end
  end

  def update
    @user = User.find(params[:id])
    new_role = params[:user][:role].to_s

    if @user.admin? && new_role != "admin"
      other_admins = User.where(role: "admin").where.not(id: @user.id).count
      if other_admins.zero?
        redirect_to users_path, alert: "Cannot demote the only admin."
        return
      end
    end

    if @user.update(role: params[:user][:role])
      redirect_to users_path, notice: "#{@user.email} updated to #{params[:user][:role]}."
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
    params.require(:user).permit(:email)
  end
end
