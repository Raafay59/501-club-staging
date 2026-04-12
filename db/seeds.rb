admin_emails = %w[raafay@tamu.edu zzh021015@tamu.edu ernest01@tamu.edu]

admin_emails.each do |email|
  User.upsert({ email: email, role: "admin" }, unique_by: :email)
  puts "Admin ensured: #{email}"
end
