class UsersController < ClubDashboardController
     before_action :require_admin

     def index
          @users = ordered_admins
          @new_user = Admin.new
     end

     def create
          requested_role = raw_admin_role
          normalized = normalized_role(requested_role, allow_unauthorized: false)
          email = permitted_admin_email
          @new_user = Admin.new(email: email, role: normalized)
          @new_user.full_name = email.to_s.split("@").first
          @new_user.uid = "invited:#{SecureRandom.uuid}"
          if @new_user.save
               redirect_to users_path, notice: "#{@new_user.email} added as #{@new_user.role}."
          else
               @users = ordered_admins
               render :index, status: :unprocessable_entity
          end
     end

     def update
          @user = Admin.find(params[:id])
          requested_role = raw_admin_role
          new_role = normalized_role(requested_role, allow_unauthorized: true)
          if new_role.blank?
               redirect_to users_path, alert: "Invalid role selected."
               return
          end

          if @user.role_admin? && new_role != "admin"
               other_admins = Admin.where(role: "admin").where.not(id: @user.id).count
               if other_admins.zero?
                    redirect_to users_path, alert: "Cannot demote the only admin."
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
          @user = Admin.find(params[:id])
          if @user == current_admin
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

       # Role is not permitted for mass assignment; it is validated via normalized_role.
       def permitted_admin_email
            params.require(:admin).permit(:email)[:email]
       end

       def raw_admin_role
            params.require(:admin)[:role]
       end

       def normalized_role(role_value, allow_unauthorized:)
            allowed = allow_unauthorized ? %w[admin editor unauthorized] : %w[admin editor]
            role = role_value.to_s
            allowed.include?(role) ? role : (allow_unauthorized ? nil : "editor")
       end

       def ordered_admins
            Admin.order(Arel.sql("CASE role WHEN 'admin' THEN 0 WHEN 'editor' THEN 1 ELSE 2 END"), :email)
       end
end
