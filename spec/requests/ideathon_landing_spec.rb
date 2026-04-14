require "rails_helper"

RSpec.describe "Public Ideathon landing (root)", type: :request do
  describe "GET /" do
    it "renders when an active year is set" do
      ideathon = Ideathon.create!(
        year: 2025,
        theme: "Innovation",
        is_active: true,
        start_date: Date.new(2025, 2, 1),
        end_date: Date.new(2025, 2, 2)
      )
      IdeathonEvent.create!(
        ideathon_year: ideathon,
        event_name: "Kickoff",
        event_description: "Start",
        event_date: Date.new(2025, 2, 1),
        event_time: "09:00"
      )

      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Kickoff")
    end

    it "falls back to the latest year with public content when none is active" do
      Ideathon.create!(
        year: 2026,
        theme: "Empty Year",
        is_active: false,
        start_date: Date.new(2026, 2, 1),
        end_date: Date.new(2026, 2, 2)
      )
      with_content = Ideathon.create!(
        year: 2025,
        theme: "Has Events",
        is_active: false,
        start_date: Date.new(2025, 2, 1),
        end_date: Date.new(2025, 2, 2)
      )
      IdeathonEvent.create!(
        ideathon_year: with_content,
        event_name: "Solo Event",
        event_description: "Only here",
        event_date: Date.new(2025, 2, 1),
        event_time: "10:00"
      )

      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Solo Event")
    end

    it "classifies sponsors into tiers by job title" do
      ideathon = Ideathon.create!(
        year: 2027,
        theme: "Sponsors",
        is_active: true,
        start_date: Date.new(2027, 2, 1),
        end_date: Date.new(2027, 2, 2)
      )
      SponsorsPartner.create!(
        ideathon: ideathon,
        name: "Big Co",
        is_sponsor: true,
        job_title: "Presenting sponsor"
      )
      SponsorsPartner.create!(
        ideathon: ideathon,
        name: "Gold Co",
        is_sponsor: true,
        job_title: "Gold sponsor"
      )
      SponsorsPartner.create!(
        ideathon: ideathon,
        name: "Other Co",
        is_sponsor: true,
        job_title: "Supporter"
      )

      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Big Co")
      expect(response.body).to include("Gold Co")
      expect(response.body).to include("Other Co")
    end
  end
end
