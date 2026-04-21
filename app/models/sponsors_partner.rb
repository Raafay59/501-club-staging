class SponsorsPartner < ApplicationRecord
     include ActivityTrackable

     belongs_to :ideathon, foreign_key: :ideathon_year_id, class_name: "Ideathon", inverse_of: :sponsors_partners, touch: true

     validates :name, presence: true
     validates :ideathon, presence: true

     validate :logo_url_must_be_http_or_https

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

       def logo_url_must_be_http_or_https
            return if logo_url.blank?

            begin
                 uri = URI.parse(logo_url)
            rescue URI::InvalidURIError
                 errors.add(:logo_url, "must be a valid URL")
                 return
            end

            errors.add(:logo_url, "must be a valid HTTP or HTTPS URL") unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
       end
end
