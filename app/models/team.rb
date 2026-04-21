##
# Model representing a team in the Ideathon event.
# Each team belongs to a year and has many registered attendees.
class Team < ApplicationRecord
     # Associations
     belongs_to :ideathon_year
     has_many :registered_attendees

     # Validations
     validates :team_name, presence: true
     # Team name must be unique within a year, unless it's an unassigned team
     validates :team_name, uniqueness: { scope: :ideathon_year_id, message: "already exists for this year" }, unless: :unassigned
end
