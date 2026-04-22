ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "omniauth"

OmniAuth.config.test_mode = true

module ActiveSupport
     class TestCase
       # Run tests in parallel with specified workers
          parallelize(workers: :number_of_processors)

       # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
          fixtures :all

       # Add more helper methods to be used by all tests here...
     end
end

# Helper for signing in with mock Google OAuth in integration tests
module OmniAuthTestHelper
     def sign_in_admin(admin = nil)
          admin ||= admins(:one)

          OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
            provider: 'google_oauth2',
            uid: admin.uid,
            info: {
              email: admin.email,
              name: admin.full_name,
              image: admin.avatar_url
            },
            credentials: {
              token: 'mock_token',
              expires_at: Time.now + 1.week
            }
          })
     end
end
