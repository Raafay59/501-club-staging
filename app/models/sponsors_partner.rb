class SponsorsPartner < ApplicationRecord
  include ActivityTrackable

  belongs_to :ideathon, foreign_key: :ideathon_year_id, class_name: "Ideathon", inverse_of: :sponsors_partners

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

  validate :logo_url_must_be_http_or_https

  private

  def logo_url_must_be_http_or_https
    return if logo_url.blank?

    uri = URI.parse(logo_url)
    unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      errors.add(:logo_url, "must be a valid HTTP or HTTPS URL")
    end
  rescue URI::InvalidURIError
    errors.add(:logo_url, "must be a valid URL")
  end
end
