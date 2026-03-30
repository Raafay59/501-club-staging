class MentorsJudge < ApplicationRecord
  include ActivityTrackable

  belongs_to :ideathon, foreign_key: :year

  validates :name, presence: true
  validates :year, presence: true
end
