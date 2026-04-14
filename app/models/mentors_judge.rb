class MentorsJudge < ApplicationRecord
  include ActivityTrackable

  belongs_to :ideathon, foreign_key: :ideathon_year_id, class_name: "Ideathon", inverse_of: :mentors_judges

  validates :name, presence: true
  validates :ideathon, presence: true

  def year
    ideathon&.year
  end

  def year=(value)
    if value.blank?
      self.ideathon = nil
      return
    end

    self.ideathon = Ideathon.find_by!(year: value.to_i)
  end
end
