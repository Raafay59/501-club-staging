Rails.application.config.after_initialize do
  next if Rails.env.test?

  admin_emails = %w[raafay@tamu.edu 501clubtestuser@gmail.com]

  admin_emails.each do |email|
    user = User.find_or_initialize_by(email: email)
    user.role = "admin"
    user.save!
  end
rescue => e
  Rails.logger.warn "[ensure_admin_users] Could not enforce admin roles: #{e.message}"
end
