# frozen_string_literal: true

# One row per competition year. Data is edited in the 501 Club dashboard and surfaced
# on the public Ideathon site (events, teams, registration).
class Ideathon < ApplicationRecord
  self.table_name = "ideathon_years"
  self.inheritance_column = nil

  include ActivityTrackable

  has_many :sponsors_partners, dependent: :destroy, foreign_key: :ideathon_year_id, inverse_of: :ideathon
  has_many :mentors_judges, dependent: :destroy, foreign_key: :ideathon_year_id, inverse_of: :ideathon
  has_many :faqs, dependent: :destroy, foreign_key: :ideathon_year_id, inverse_of: :ideathon
  has_many :rules, dependent: :destroy, foreign_key: :ideathon_year_id, inverse_of: :ideathon
  has_many :teams, dependent: :destroy, foreign_key: :ideathon_year_id, inverse_of: :ideathon_year
  has_many :registered_attendees, dependent: :restrict_with_error, foreign_key: :ideathon_year_id, inverse_of: :ideathon_year
  has_many :ideathon_events, dependent: :destroy, foreign_key: :ideathon_year_id, inverse_of: :ideathon_year

  validates :year, presence: true, uniqueness: true, numericality: { only_integer: true }

  before_validation :assign_default_name

  def to_param
    year.to_s
  end

  private

  def assign_default_name
    self.name = "Ideathon #{year}" if year.present? && name.blank?
  end
end
