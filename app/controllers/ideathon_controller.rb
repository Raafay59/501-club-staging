##
# Controller for the public Ideathon landing page.
# Shows the current active year and its events.
class IdeathonController < ApplicationController
     # Allow public access to the index page (no admin required)
     skip_before_action :require_organizer_tools!, only: :index

     # GET /ideathon
     # Shows the main Ideathon page with the active year and its events
     def index
          @ideathon_year = public_ideathon_year
          @events = @ideathon_year&.ideathon_events&.order(:event_date, :event_time) || []
          load_public_sponsors_and_judges
          load_public_faqs_and_rules
          render layout: "ideathon"
     end

     private

     # Prefer the year marked active in the dashboard. If none is set, use the latest year that has
     # public content (sponsors, judges, or schedule) so data is not hidden behind a newer empty year.
     def public_ideathon_year
          active = Ideathon.find_by(is_active: true)
          return active if active

          ordered = Ideathon.includes(
            :sponsors_partners,
            :mentors_judges,
            :ideathon_events,
            :faqs,
            :rules
          ).order(year: :desc)
          ordered.find do |y|
            y.sponsors_partners.any? ||
              y.mentors_judges.any? ||
              y.ideathon_events.any? ||
              y.faqs.any? ||
              y.rules.any?
          end || ordered.first
     end

     def load_public_sponsors_and_judges
          @sponsor_presenting = []
          @sponsor_gold = []
          @sponsor_other = []
          @community_partners = []
          @judges = []
          @mentors = []

          return unless @ideathon_year

          all_rows = @ideathon_year.sponsors_partners.order(:name)
          marked_sponsors = all_rows.where(is_sponsor: true)
          # Schema defaults is_sponsor to false; if nothing is checked, still show orgs in sponsor tiers.
          tier_rows = marked_sponsors.any? ? marked_sponsors : all_rows
          tier_rows.each do |sp|
               t = sp.job_title.to_s.downcase
               if t.include?("presenting")
                    @sponsor_presenting << sp
               elsif t.include?("gold")
                    @sponsor_gold << sp
               else
                    @sponsor_other << sp
               end
          end

          @community_partners = if marked_sponsors.any?
               all_rows.where(is_sponsor: false).order(:name)
          else
               []
          end

          @judges = @ideathon_year.mentors_judges.where(is_judge: true).order(:name)
          @mentors = @ideathon_year.mentors_judges.where(is_judge: false).order(:name)
     end

     def load_public_faqs_and_rules
          @faqs = []
          @rules = []
          return unless @ideathon_year

          @faqs = @ideathon_year.faqs.order(:id).to_a
          @rules = @ideathon_year.rules.order(:id).to_a
     end
end
