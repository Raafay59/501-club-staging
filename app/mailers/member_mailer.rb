class MemberMailer < ApplicationMailer
    default from: "no-reply@IdeathonAdminTeam.com"

    def role_change_email
        @user = params[:user]
        @old_role = params[:old_role]
        @new_role = params[:new_role]

        mail(to: @user.email, subject: "Your role has been changed")
    end

    def welcome_email
        @user = params[:user]
        @new_role = params[:new_role]

        mail(to: @user.email, subject: "Welcome to the Ideathon Organizer Team!")
    end

    def goodbye_email
        @user = params[:user]
        @old_role = params[:old_role]

        mail(to: @user.email, subject: "Removed from the Ideathon Organizer Team")
    end
end
