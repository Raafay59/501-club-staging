admin_emails = %w[raafay@tamu.edu zzh021015@tamu.edu ernest01@tamu.edu t47735295@gmail.com]

admin_emails.each do |email|
  User.upsert({ email: email, role: "admin" }, unique_by: :email)
  puts "Admin ensured: #{email}"
end

# Public Ideathon FAQs and rules (matches former static copy). Only fills empty years so re-runs do not duplicate.
ideathon =
  Ideathon.find_by(is_active: true) ||
  Ideathon.find_by(year: 2026) ||
  Ideathon.order(year: :desc).first

unless ideathon
  ideathon = Ideathon.create!(
    year: 2026,
    name: "Ideathon 2026",
    start_date: Date.new(2026, 2, 28),
    end_date: Date.new(2026, 3, 1),
    is_active: true
  )
  puts "Created default Ideathon year #{ideathon.year}"
end

if ideathon.faqs.empty?
  [
    [
      "Who can participate?",
      "Any current Texas A&M student with a valid @tamu.edu email can participate. All majors and skill levels are welcome - you don't need to be a CS major or know how to code!"
    ],
    [
      "Do I need a team?",
      "Teams of 2-4 are required, but you don't need one to register! We'll have team formation activities at the start of the event to help you find like-minded collaborators."
    ],
    [
      "What should I bring?",
      "Bring your laptop, chargers, and any hardware you want to use. We'll provide food, drinks, snacks, WiFi, and a comfortable workspace. Sleeping bags/blankets are recommended if you plan to stay overnight!"
    ],
    [
      "Is it free to attend?",
      "Yes! TAMU Ideathon is completely free for all participants. Food, swag, and all workshop materials are provided at no cost."
    ],
    [
      "Do I need to know how to code?",
      "No coding experience required! This is an <strong>ideathon</strong>, not just a hackathon. We value creative problem-solving, design thinking, business acumen, and presentation skills just as much as technical ability."
    ]
  ].each do |question, answer|
    ideathon.faqs.create!(question: question, answer: answer)
  end
  puts "Seeded #{ideathon.faqs.count} FAQs for Ideathon #{ideathon.year}"
end

if ideathon.rules.empty?
  [
    [ "Original Work", "All work must be created during the Ideathon." ],
    [ "AI Tools Permitted", "Use of AI tools is permitted unless otherwise specified." ],
    [ "Pitch Deck Required", "Teams must submit their pitch deck before the deadline." ],
    [ "No Late Submissions", "Late submissions will not be judged." ],
    [ "One Presentation", "One presentation per team." ]
  ].each do |title, body|
    ideathon.rules.create!(rule_text: "#{title}\n\n#{body}")
  end
  puts "Seeded #{ideathon.rules.count} rules for Ideathon #{ideathon.year}"
end
