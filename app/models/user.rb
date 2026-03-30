class User < ApplicationRecord
  ROLES = %w[admin editor unauthorized].freeze

  has_many :activity_logs, dependent: :restrict_with_error

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

  after_update :send_role_change_email, if: :saved_change_to_role?
  after_create :send_welcome_email, if: :authorized?
  after_create :send_request_email, if: :unauthorized?
  after_destroy :send_goodbye_email

  private 

  def send_role_change_email
    Rails.logger.debug "ROLE CHANGED TRIGGERED"
    old_role, new_role = saved_change_to_role
    MemberMailer.with(user: self, old_role: old_role, new_role: new_role).role_change_email.deliver_later
  end

  def send_welcome_email
    MemberMailer.with(user: self, new_role: role).welcome_email.deliver_later
  end

  def send_goodbye_email
    MemberMailer.with(user: self).goodbye_email.deliver_later
  end

  def send_request_email
    User.where(role: "admin").find_each do |admin|
      MemberMailer.with(user: admin, requester: self).request_email.deliver_later
    end
  end

end
