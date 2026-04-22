module OmniAuthHelper
     def mock_google_oauth2(admin_attributes = {})
          attrs = {
            email: "test@tamu.edu",
            full_name: "Test User",
            uid: "123456789",
            avatar_url: "https://example.com/avatar.jpg"
          }.merge(admin_attributes)

          OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
            provider: "google_oauth2",
            uid: attrs[:uid],
            info: {
              email: attrs[:email],
              name: attrs[:full_name],
              image: attrs[:avatar_url]
            },
            credentials: { token: "mock_token", expires_at: 1.week.from_now }
          )
     end
end

RSpec.configure do |config|
     config.include OmniAuthHelper, type: :system
     config.include OmniAuthHelper, type: :request

     config.before(:each) do
          OmniAuth.config.test_mode = true
     end

     config.after(:each) do
          OmniAuth.config.mock_auth[:google_oauth2] = nil
     end
end
