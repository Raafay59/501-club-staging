# frozen_string_literal: true

# Resolves the current ideathon year used by organizer tools.
# Prefers the explicitly active year and falls back to the latest configured year.
class ActiveIdeathonYear
  class << self
    def call(create_if_missing: false)
      Ideathon.find_by(is_active: true) ||
        Ideathon.order(year: :desc, created_at: :desc).first ||
        (create_if_missing ? create_default_year! : nil)
    end

    private

    def create_default_year!
      today = Time.zone.today
      Ideathon.create!(
        year: today.year,
        start_date: today,
        end_date: today + 1.day,
        is_active: true,
        description: "Auto-generated default year"
      )
    end
  end
end
