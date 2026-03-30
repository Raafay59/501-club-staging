class Faq < ApplicationRecord
  include ActivityTrackable

  belongs_to :ideathon, foreign_key: :year

  validates :question, presence: true
  validates :answer, presence: true
  validates :year, presence: true
end
