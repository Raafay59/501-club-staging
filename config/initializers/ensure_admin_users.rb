Rails.application.config.after_initialize do
  next if Rails.env.test?

  admin_emails = %w[raafay@tamu.edu zzh021015@tamu.edu ernest01@tamu.edu t47735295@gmail.com]

  admin_emails.each do |email|
    User.upsert({ email: email, role: "admin" }, unique_by: :email)
  end
rescue => e
  Rails.logger.warn "[ensure_admin_users] Could not enforce admin roles: #{e.message}"
end
