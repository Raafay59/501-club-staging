class ActivityLog < ApplicationRecord
  belongs_to :user

  ACTIONS = %w[added edited removed].freeze

  validates :action, inclusion: { in: ACTIONS }
  validates :message, presence: true

  def self.record!(user:, action:, message:)
    create!(user: user, action: action.to_s, message: message)
  end
end
