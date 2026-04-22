# frozen_string_literal: true

class ActiveIdeathonYear
     class << self
          def call(create_if_missing: false, prefer_content: false)
               active = IdeathonYear.find_by(is_active: true)
               return active if active

               if prefer_content
                    with_content = IdeathonYear
                      .where(
                        <<~SQL.squish
                          EXISTS (SELECT 1 FROM sponsors_partners sp WHERE sp.ideathon_year_id = ideathon_years.id)
                          OR EXISTS (SELECT 1 FROM mentors_judges mj WHERE mj.ideathon_year_id = ideathon_years.id)
                          OR EXISTS (SELECT 1 FROM ideathon_events ie WHERE ie.ideathon_year_id = ideathon_years.id)
                          OR EXISTS (SELECT 1 FROM faqs f WHERE f.ideathon_year_id = ideathon_years.id)
                          OR EXISTS (SELECT 1 FROM rules r WHERE r.ideathon_year_id = ideathon_years.id)
                        SQL
                      )
                      .order(year: :desc, updated_at: :desc, created_at: :desc)
                      .first
                    return with_content if with_content
               end

               IdeathonYear.order(year: :desc, updated_at: :desc, created_at: :desc).first ||
                 (create_if_missing ? create_default_year! : nil)
          end

       private

            def create_default_year!
                 today = Time.zone.today
                 IdeathonYear.find_or_create_by!(year: today.year) do |ideathon|
                      ideathon.start_date = today
                      ideathon.end_date = today + 1.day
                      ideathon.is_active = true
                      ideathon.name = "Ideathon #{today.year}"
                      ideathon.description = "Auto-generated default year"
                 end
            rescue ActiveRecord::RecordNotUnique
                 IdeathonYear.find_by(is_active: true) ||
                   IdeathonYear.order(year: :desc, created_at: :desc).first ||
                   IdeathonYear.find_by!(year: today.year)
            end
     end
end
