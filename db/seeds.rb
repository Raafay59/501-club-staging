admin_emails = %w[raafay@tamu.edu 501clubtestuser@gmail.com]

admin_emails.each do |email|
  User.find_or_create_by!(email: email) do |user|
    user.role = "admin"
  end
end
