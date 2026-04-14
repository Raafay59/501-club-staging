##
# Model representing a student registered for the Ideathon event.
# Handles validation, search, and team association logic.
class RegisteredAttendee < ApplicationRecord
     # Associations
     belongs_to :ideathon_year, class_name: "Ideathon", inverse_of: :registered_attendees
     belongs_to :team, optional: true

     # Validations
     validates :ideathon_year_id, :attendee_name, :attendee_phone, :attendee_email, :attendee_major, :attendee_class, presence: true
     validate :phone_must_have_ten_digits
     validate :email_must_be_tamu

     # Default ordering by attendee name
     default_scope { order(attendee_name: :asc) }

     # Scopes for searching and sorting
     scope :search_by_name, ->(query) {
          where("attendee_name ILIKE ?", "%#{query}%") if query.present?
     }

     # Search by attendee name or team name
     scope :search_by_name_or_team, ->(query) {
          if query.present?
               left_joins(:team).where(
                    "attendee_name ILIKE :q OR teams.team_name ILIKE :q",
                    q: "%#{query}%"
               )
          end
     }

     # Sort attendees by team name, then attendee name
     scope :sorted_by_team, -> {
          reorder(nil).left_joins(:team).order("teams.team_name ASC NULLS LAST, attendee_name ASC")
     }

     private

          # Validates that the email is a TAMU address
          def email_must_be_tamu
               if attendee_email.present? && !attendee_email.end_with?("@tamu.edu")
                    errors.add(:attendee_email, "must be a @tamu.edu address")
               end
          end

          # Validates that the phone number contains exactly 10 digits
          def phone_must_have_ten_digits
               if attendee_phone.present?
                    digit_count = attendee_phone.gsub(/\D/, "").length
                    if digit_count != 10
                         errors.add(:attendee_phone, "must contain exactly 10 digits")
                    end
               end
          end
end
