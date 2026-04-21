##
# Model representing a team in the Ideathon event.
# Each team belongs to a year and has many registered attendees.
class Team < ApplicationRecord
     # Associations
     belongs_to :ideathon_year
     has_many :registered_attendees

     before_validation :normalize_team_name

     # Validations
     validates :team_name, presence: true
     # Team name must be unique within a year, unless it's an unassigned team
     validates :team_name,
          uniqueness: {
               scope: :ideathon_year_id,
               case_sensitive: false,
               message: "already exists for this year"
          },
          unless: :unassigned

  private

       def normalize_team_name
            self.team_name = team_name.to_s.squish.presence
       end
end
