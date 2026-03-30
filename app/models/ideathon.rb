class Ideathon < ApplicationRecord
  include ActivityTrackable

  self.primary_key = :year

  has_many :sponsors_partners, foreign_key: :year, dependent: :destroy
  has_many :mentors_judges, foreign_key: :year, dependent: :destroy
  has_many :faqs, foreign_key: :year, dependent: :destroy
  has_many :rules, foreign_key: :year, dependent: :destroy

  validates :year, presence: true, uniqueness: true, numericality: { only_integer: true }
end
