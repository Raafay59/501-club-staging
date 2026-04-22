# frozen_string_literal: true

require "rails_helper"

# IdeathonController serves the public landing page at root (GET /).
# No sign-in required; it shows the event info and links to Register (attendees) and Login (admins).
RSpec.describe "Ideathon (public landing)", type: :request do
     describe "GET /" do
          it "returns success without authentication" do
               get root_path
               expect(response).to have_http_status(:ok)
          end

          it "renders content for active year including sponsors, mentors, faqs, and rules" do
               year = Ideathon.create!(year: 2026, name: "Ideathon 2026", is_active: true)
               SponsorsPartner.create!(ideathon: year, name: "Presenting Sponsor", is_sponsor: true, job_title: "Presenting")
               SponsorsPartner.create!(ideathon: year, name: "Community Partner", is_sponsor: false)
               MentorsJudge.create!(ideathon: year, name: "Judge Judy", is_judge: true)
               MentorsJudge.create!(ideathon: year, name: "Mentor Mike", is_judge: false)
               Faq.create!(ideathon: year, question: "What is this?", answer: "Ideathon")
               Rule.create!(ideathon: year, rule_text: "Have fun")

               get root_path

               expect(response).to have_http_status(:ok)
               expect(response.body).to include("Presenting Sponsor")
               expect(response.body).to include("Community Partner")
               expect(response.body).to include("Judge Judy")
               expect(response.body).to include("Mentor Mike")
               expect(response.body).to include("What is this?")
               expect(response.body).to include("Have fun")
          end
     end
end
