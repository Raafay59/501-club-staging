# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Heroku release phase runs `db:seed` on every deploy (matching 501-club-staging). Keep production seeds minimal and
# non-destructive: never overwrite an existing Ideathon year's organizer-edited fields.

year = IdeathonYear.find_or_initialize_by(year: 2026)
if year.new_record?
     year.assign_attributes(
       name: "Ideathon 2026",
       description: "Spring ProductTAMU Ideathon",
       location: "Texas A&M University",
       start_date: Date.new(2026, 4, 11),
       end_date: Date.new(2026, 4, 12),
       is_active: true
     )
     # Legacy 501-club-staging DBs enforce at most one active year via a partial unique index.
     # Clear other active flags before inserting a new active year so release-phase seeding cannot fail.
     if year.is_active
          IdeathonYear.where(is_active: true).update_all(is_active: false, updated_at: Time.current)
     end
end
year.save!

# Seed Ideathon Events (idempotent: does not update existing rows)
events_data = [
     # Day 1 Events
     { event_name: "Check-in & Breakfast", event_description: "Registration and team formation", event_date: Date.new(2026, 4, 11), event_time: Time.parse("09:00") },
     { event_name: "Opening Ceremony", event_description: "Keynote speaker & rules announcement", event_date: Date.new(2026, 4, 11), event_time: Time.parse("10:00") },
     { event_name: "Hacking Begins!", event_description: "24 hours on the clock", event_date: Date.new(2026, 4, 11), event_time: Time.parse("11:00") },
     { event_name: "Workshops & Mentoring", event_description: "Design thinking, pitching, tech sessions", event_date: Date.new(2026, 4, 11), event_time: Time.parse("14:00") },
     { event_name: "Dinner", event_description: "Dinner for all participants", event_date: Date.new(2026, 4, 11), event_time: Time.parse("18:00") },

     # Day 2 Events
     { event_name: "Submissions Due", event_description: "Final project submission deadline", event_date: Date.new(2026, 4, 12), event_time: Time.parse("11:00") },
     { event_name: "Judging Begins", event_description: "Teams present to judges", event_date: Date.new(2026, 4, 12), event_time: Time.parse("12:00") },
     { event_name: "Lunch", event_description: "Lunch for all participants", event_date: Date.new(2026, 4, 12), event_time: Time.parse("12:30") },
     { event_name: "Closing Ceremony", event_description: "Award ceremony and recognition", event_date: Date.new(2026, 4, 12), event_time: Time.parse("15:00") }
]

events_data.each do |event_data|
     IdeathonEvent.find_or_create_by!(
          ideathon_year: year,
          event_name: event_data[:event_name],
          event_date: event_data[:event_date]
     ) do |e|
          e.event_description = event_data[:event_description]
          e.event_time = event_data[:event_time]
     end
end

# Ensure an "Unassigned" team exists (required by registration form)
Team.find_or_create_by!(ideathon_year: year, unassigned: true) do |t|
     t.team_name = "Unassigned"
end

# Sample teams and attendees are for local/demo only (never run on production Heroku).
sample_ok = !Rails.env.production? || ActiveModel::Type::Boolean.new.cast(ENV["SEED_SAMPLE_DATA"])

if sample_ok
     team_names = [ "Alpha Builders", "Code Crusaders", "Pixel Pirates", "Data Dragons" ]
     teams = team_names.map do |name|
          Team.find_or_create_by!(ideathon_year: year, team_name: name) do |t|
               t.unassigned = false
          end
     end

     attendees_data = [
          { name: "Alice Johnson",    email: "alice.johnson@tamu.edu",    phone: "979-555-0101", major: "Computer Science",      classification: "Junior" },
          { name: "Bob Martinez",     email: "bob.martinez@tamu.edu",     phone: "979-555-0102", major: "Electrical Engineering", classification: "Senior" },
          { name: "Charlie Kim",      email: "charlie.kim@tamu.edu",      phone: "979-555-0103", major: "Computer Engineering",   classification: "Sophomore" },
          { name: "Diana Patel",      email: "diana.patel@tamu.edu",      phone: "979-555-0104", major: "Data Science",           classification: "Junior" },
          { name: "Ethan Brown",      email: "ethan.brown@tamu.edu",      phone: "979-555-0105", major: "Computer Science",       classification: "Senior" },
          { name: "Fiona Chen",       email: "fiona.chen@tamu.edu",       phone: "979-555-0106", major: "Mathematics",            classification: "Freshman" },
          { name: "George Davis",     email: "george.davis@tamu.edu",     phone: "979-555-0107", major: "Mechanical Engineering", classification: "Junior" },
          { name: "Hannah Lee",       email: "hannah.lee@tamu.edu",       phone: "979-555-0108", major: "Computer Science",       classification: "Sophomore" },
          { name: "Isaac Wilson",     email: "isaac.wilson@tamu.edu",     phone: "979-555-0109", major: "Physics",                classification: "Senior" },
          { name: "Julia Nguyen",     email: "julia.nguyen@tamu.edu",     phone: "979-555-0110", major: "Computer Science",       classification: "Junior" },
          { name: "Kevin Thompson",   email: "kevin.thompson@tamu.edu",   phone: "979-555-0111", major: "Industrial Engineering", classification: "Sophomore" },
          { name: "Laura Garcia",     email: "laura.garcia@tamu.edu",     phone: "979-555-0112", major: "Biomedical Engineering", classification: "Senior" },
          { name: "Marcus Wright",    email: "marcus.wright@tamu.edu",    phone: "979-555-0113", major: "Computer Science",       classification: "Freshman" },
          { name: "Nadia Hassan",     email: "nadia.hassan@tamu.edu",     phone: "979-555-0114", major: "Aerospace Engineering",  classification: "Junior" },
          { name: "Oscar Rivera",     email: "oscar.rivera@tamu.edu",     phone: "979-555-0115", major: "Computer Science",       classification: "Senior" },
          { name: "Priya Sharma",     email: "priya.sharma@tamu.edu",     phone: "979-555-0116", major: "Statistics",             classification: "Sophomore" },
          { name: "Quinn O'Brien",    email: "quinn.obrien@tamu.edu",     phone: "979-555-0117", major: "Computer Science",       classification: "Junior" },
          { name: "Rachel Adams",     email: "rachel.adams@tamu.edu",     phone: "979-555-0118", major: "Chemical Engineering",   classification: "Senior" },
          { name: "Sam Taylor",       email: "sam.taylor@tamu.edu",       phone: "979-555-0119", major: "Computer Science",       classification: "Freshman" },
          { name: "Tina Zhao",        email: "tina.zhao@tamu.edu",        phone: "979-555-0120", major: "Information Technology",  classification: "Junior" }
     ]

     unassigned_team = Team.find_by!(ideathon_year: year, unassigned: true)

     attendees_data.each_with_index do |data, i|
          team = i < 16 ? teams[i % 4] : unassigned_team

          RegisteredAttendee.find_or_create_by!(attendee_email: data[:email]) do |a|
               a.attendee_name  = data[:name]
               a.attendee_phone = data[:phone]
               a.attendee_major = data[:major]
               a.attendee_class = data[:classification]
               a.ideathon_year  = year
               a.team           = team
          end
     end
end
