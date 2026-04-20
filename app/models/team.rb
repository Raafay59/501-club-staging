##
# Model representing a team in the Ideathon event.
# Each team belongs to a year and has many registered attendees.
class Team < ApplicationRecord
  # Associations
  belongs_to :ideathon_year, class_name: "Ideathon", inverse_of: :teams
  has_many :registered_attendees

  # Validations
  validates :unassigned, inclusion: { in: [ true, false ] }
  validates :team_name, presence: true
  # Team name must be unique within a year, unless it's an unassigned team
  validates :team_name, uniqueness: {
    scope: :ideathon_year_id,
    case_sensitive: false,
    message: "already exists for this year"
  }, unless: :unassigned

  validate :single_unassigned_team_per_year, if: :unassigned

  private

  def single_unassigned_team_per_year
    return if ideathon_year_id.blank?

    existing = Team.where(ideathon_year_id: ideathon_year_id, unassigned: true)
    existing = existing.where.not(id: id) if persisted?
    return unless existing.exists?

    errors.add(:ideathon_year_id, "already has an unassigned team")
  end
end
