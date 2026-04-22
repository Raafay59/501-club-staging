# frozen_string_literal: true

# Shared logic for models that map to the `ideathon_years` table.
# Applied to both `IdeathonYear` (used by seeds/public/legacy code paths) and
# `Ideathon` (used by the dashboard) so both classes validate and behave
# consistently when writing to the same underlying table.
module IdeathonYearShared
     extend ActiveSupport::Concern

     included do
          has_many :registered_attendees, dependent: :destroy, foreign_key: :ideathon_year_id
          has_many :teams, dependent: :destroy, foreign_key: :ideathon_year_id
          has_many :ideathon_events, dependent: :destroy, foreign_key: :ideathon_year_id
          has_many :sponsors_partners, dependent: :destroy, foreign_key: :ideathon_year_id
          has_many :mentors_judges, dependent: :destroy, foreign_key: :ideathon_year_id
          has_many :faqs, dependent: :destroy, foreign_key: :ideathon_year_id
          has_many :rules, dependent: :destroy, foreign_key: :ideathon_year_id

          validates :year,
                    presence: true,
                    uniqueness: true,
                    numericality: {
                      only_integer: true,
                      greater_than_or_equal_to: 2000,
                      less_than_or_equal_to: 2100
                    }

          before_validation :populate_year, if: -> { year.blank? }
          before_validation :assign_default_name
     end

  private

       def populate_year
            extracted = name.to_s[/\b(19|20)\d{2}\b/]
            self.year = extracted.to_i if extracted.present?
            self.year ||= start_date&.year
       end

       def assign_default_name
            return if name.present?
            return if year.blank?

            self.name = "Ideathon #{year}"
       end
end
