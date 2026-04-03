admin_emails = %w[raafay@tamu.edu zzh021015@tamu.edu]

admin_emails.each do |email|
  user = User.find_or_initialize_by(email: email)
  user.role = "admin"
  user.save!
  puts "Admin ensured: #{email}"
end
