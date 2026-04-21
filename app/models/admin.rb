##
# Model for Ideathon administrators.
# Handles authentication via Google OAuth and admin allowlist logic.
class Admin < ApplicationRecord
     # Use Devise for authentication, with Google OAuth2 as the provider
     devise :omniauthable, omniauth_providers: [ :google_oauth2 ]

     has_many :manager_action_logs, dependent: :nullify
     has_many :activity_logs, dependent: :nullify

     enum :role, { admin: "admin", editor: "editor", unauthorized: "unauthorized" }, prefix: :role
     validates :email, presence: true, format: { with: /\A[^@\s]+@tamu\.edu\z/i, message: "must end with @tamu.edu" }

     # Only emails in the allowlist can sign in as admin.
     # Returns true if the email is in the allowed admin list (from ENV)
     def self.allowed_email?(email)
          normalized_email = email.to_s.strip.downcase
          return false if normalized_email.blank?

          # Accept comma, semicolon, or newline separated env values
          raw = ENV.fetch("ALLOWED_ADMIN_EMAILS", "").to_s
          list = raw.split(/[,\n;]+/).map { |e| e.to_s.strip.downcase }.reject(&:blank?)

          # Explicit allowlist wins when set (recommended for production).
          return list.include?(normalized_email) if list.any?

          # Cutover / backward compatibility: when no allowlist is configured, allow
          # @tamu.edu sign-in for legacy `users` rows that were admins or editors (501-club-staging).
          return false unless normalized_email.end_with?("@tamu.edu")

          if Admin.connection.table_exists?("users") &&
               Admin.connection.column_exists?(:users, :email) &&
               Admin.connection.column_exists?(:users, :role)
               sql = ActiveRecord::Base.sanitize_sql_array(
                    [
                      "SELECT 1 FROM users WHERE lower(trim(email)) = ? AND role IN ('admin','editor') LIMIT 1",
                      normalized_email
                    ]
               )
               return true if Admin.connection.select_value(sql).present?
          end

          false
     end

     # Finds or creates an admin from Google OAuth data, if allowed
     def self.from_google(email:, full_name:, uid:, avatar_url:)
          return nil unless allowed_email?(email)
          admin = find_or_initialize_by(email: email)
          admin.assign_attributes(uid: uid, full_name: full_name, avatar_url: avatar_url)
          admin.role = "editor" if admin.new_record?
          admin.save!
          admin
     end

     def authorized?
          !role_unauthorized?
     end
end
