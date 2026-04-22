# frozen_string_literal: true

# Shared HTTP(S) URL checks for optional URL columns (identical error messages per attribute).
module HttpUrlValidation
     extend ActiveSupport::Concern

     private

       def validate_http_or_https_url(attribute)
            value = public_send(attribute)
            return if value.blank?

            begin
                 uri = URI.parse(value)
            rescue URI::InvalidURIError
                 errors.add(attribute, "must be a valid URL")
                 return
            end

            errors.add(attribute, "must be a valid HTTP or HTTPS URL") unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
       end
end
