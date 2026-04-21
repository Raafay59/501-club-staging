class MentorsJudge < ApplicationRecord
  include ActivityTrackable

  belongs_to :ideathon, foreign_key: :ideathon_year_id, class_name: "Ideathon", inverse_of: :mentors_judges

  validates :name, presence: true
  validates :ideathon, presence: true
  validate :photo_url_must_be_http_or_https

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

  private

  def photo_url_must_be_http_or_https
    return if photo_url.blank?

    uri = URI.parse(photo_url)
    unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      errors.add(:photo_url, "must be a valid HTTP or HTTPS URL")
    end
  rescue URI::InvalidURIError
    errors.add(:photo_url, "must be a valid URL")
  end
end
