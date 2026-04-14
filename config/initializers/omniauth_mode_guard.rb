# Ensure OmniAuth mock mode is never active outside test.
# If the app boots with RAILS_ENV=test accidentally, OAuth can bypass
# Google account selection and immediately fail authorization.
OmniAuth.config.test_mode = Rails.env.test?
