class CrudMailer < ApplicationMailer
    def record_change_email
        @user = params[:user]
        @change_type = params[:change_type]
        @actor = params[:actor]
        @change_message = params[:change_message]
        @item_name = params[:item_name]
        @changed_at = params[:changed_at]

        mail(to: @user.email, subject: "A record has been #{@change_type}")
    end
end
