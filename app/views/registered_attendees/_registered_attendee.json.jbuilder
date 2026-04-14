json.extract! registered_attendee, :id, :ideathon_year_id, :team_id, :attendee_name, :attendee_phone, :attendee_email, :attendee_major, :attendee_class, :created_at, :updated_at
json.url registered_attendee_url(registered_attendee, format: :json)
