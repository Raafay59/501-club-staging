##
# Controller for the public Ideathon landing page.
# Shows the current active year and its events.
class IdeathonController < ApplicationController
     # Allow public access to the index page (no admin required)
     skip_before_action :authenticate_admin!, only: :index

     # GET /ideathon
     # Shows the main Ideathon page with the active year and its events
     def index
          @ideathon_year = ActiveIdeathonYear.call(prefer_content: true)
          @events = @ideathon_year&.ideathon_events&.order(:event_date, :event_time) || []
          load_public_sponsors_and_judges
          load_public_faqs_and_rules
          render layout: "ideathon"
     end

  private

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
            tier_rows = marked_sponsors.any? ? marked_sponsors : all_rows

            tier_rows.each do |sponsor|
                 tier_name = sponsor.job_title.to_s.downcase
                 if tier_name.include?("presenting")
                      @sponsor_presenting << sponsor
                 elsif tier_name.include?("gold")
                      @sponsor_gold << sponsor
                 else
                      @sponsor_other << sponsor
                 end
            end

            @community_partners = marked_sponsors.any? ? all_rows.where(is_sponsor: false).order(:name).to_a : []
            @judges = @ideathon_year.mentors_judges.where(is_judge: true).order(:name).to_a
            @mentors = @ideathon_year.mentors_judges.where(is_judge: false).order(:name).to_a
       end

       def load_public_faqs_and_rules
            @faqs = []
            @rules = []
            return unless @ideathon_year

            @faqs = @ideathon_year.faqs.order(:id).to_a
            @rules = @ideathon_year.rules.order(:id).to_a
       end
end
