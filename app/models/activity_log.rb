class ActivityLog < ApplicationRecord
  belongs_to :user

  ACTIONS = %w[added edited removed].freeze

  validates :action, inclusion: { in: ACTIONS }
  validates :message, presence: true

  def self.record!(user:, action:, message:)
    create!(user: user, action: action.to_s, message: message)
  end

  def email_organizers
    User.where(role: [ "admin", "editor" ]).find_each do |u|
      CrudMailer.with(
        user: u,
        change_type: action.to_s,
        actor: user
      ).record_change_email.deliver_later
    end
  end
end
