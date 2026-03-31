class SponsorsPartner < ApplicationRecord
  include ActivityTrackable

  belongs_to :ideathon, foreign_key: :year

  validates :name, presence: true
  validates :year, presence: true

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
