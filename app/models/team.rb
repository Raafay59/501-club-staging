##
# Model representing a team in the Ideathon event.
# Each team belongs to a year and has many registered attendees.
class Team < ApplicationRecord
     # Associations
     belongs_to :ideathon_year
     has_many :registered_attendees

     before_validation :normalize_team_name

     # Validations
     validate :at_most_one_unassigned_team_per_ideathon_year, if: -> { unassigned? }
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

       def at_most_one_unassigned_team_per_ideathon_year
            return if ideathon_year_id.blank?

            others = Team.where(ideathon_year_id: ideathon_year_id, unassigned: true)
            others = others.where.not(id: id) if persisted?

            return unless others.exists?

            errors.add(:base, "Only one unassigned pool team is allowed per ideathon year.")
       end
end
