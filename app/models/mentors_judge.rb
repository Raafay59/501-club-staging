class MentorsJudge < ApplicationRecord
     include ActivityTrackable
     include AssignsIdeathonByYear
     include HttpUrlValidation

     belongs_to :ideathon, foreign_key: :ideathon_year_id, class_name: "Ideathon", inverse_of: :mentors_judges, touch: true

     validates :name, presence: true
     validates :ideathon, presence: true
     validate :photo_url_must_be_http_or_https

  private

       def photo_url_must_be_http_or_https
            validate_http_or_https_url(:photo_url)
       end
end
