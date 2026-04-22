class SponsorsPartner < ApplicationRecord
     include ActivityTrackable
     include AssignsIdeathonByYear
     include HttpUrlValidation

     belongs_to :ideathon, foreign_key: :ideathon_year_id, class_name: "Ideathon", inverse_of: :sponsors_partners, touch: true

     validates :name, presence: true
     validates :ideathon, presence: true

     validate :logo_url_must_be_http_or_https

  private

       def logo_url_must_be_http_or_https
            validate_http_or_https_url(:logo_url)
       end
end
