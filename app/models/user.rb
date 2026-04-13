class User < ApplicationRecord
  ROLES = %w[admin editor unauthorized].freeze

  has_many :activity_logs, dependent: :delete_all

  validates :email, presence: true, uniqueness: true
  validates :role, presence: true, inclusion: { in: ROLES }

  def admin?
    role == "admin"
  end

  def editor?
    role == "editor"
  end

  def unauthorized?
    role == "unauthorized"
  end

  def authorized?
    admin? || editor?
  end

  after_update_commit :send_role_change_email, if: :saved_change_to_role?
  after_create_commit :send_welcome_email, if: :authorized?
  before_destroy :capture_goodbye_email_attributes
  after_destroy_commit :send_goodbye_email

  def send_role_change_email
    old_role, new_role = saved_change_to_role
    MemberMailer.with(user: self, old_role: old_role, new_role: new_role).role_change_email.deliver_now
  rescue StandardError => error
    Rails.logger.error("Role change email failed for user #{id}: #{error.class}: #{error.message}")
  end

  def send_welcome_email
    MemberMailer.with(user: self, new_role: role).welcome_email.deliver_later
  rescue StandardError => error
    Rails.logger.error("Welcome email failed for user #{id}: #{error.class}: #{error.message}")
  end

  def send_goodbye_email
    MemberMailer.with(
      user_email: @goodbye_email || email,
      user_name: @goodbye_name || name,
      old_role: @goodbye_role || role
    ).goodbye_email.deliver_later
  rescue StandardError => error
    Rails.logger.error("Goodbye email failed for user #{id}: #{error.class}: #{error.message}")
  end

  def send_request_email
    User.where(role: "admin").find_each do |admin|
      MemberMailer.with(user: admin, requester: self).request_email.deliver_later
    rescue StandardError => error
      Rails.logger.error("Request email failed for admin #{admin.id}: #{error.class}: #{error.message}")
    end
  end

  private

  def capture_goodbye_email_attributes
    @goodbye_email = email
    @goodbye_name = name
    @goodbye_role = role
  end
end
