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
      Ideathon.find_or_create_by!(year: today.year) do |ideathon|
        ideathon.start_date = today
        ideathon.end_date = today + 1.day
        ideathon.is_active = true
        ideathon.description = "Auto-generated default year"
      end
    rescue ActiveRecord::RecordNotUnique
      Ideathon.find_by(is_active: true) ||
        Ideathon.order(year: :desc, created_at: :desc).first ||
        Ideathon.find_by!(year: today.year)
    end
  end
end
