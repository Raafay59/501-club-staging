# frozen_string_literal: true

##
# Controller for the public Ideathon landing page.
# Shows the current active year and its events.
class IdeathonController < ApplicationController
  # Allow public access to the index page (no admin required)
  skip_before_action :require_organizer_tools!, only: :index

  # GET /
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

    with_content = Ideathon
      .where(
        <<~SQL.squish
          EXISTS (SELECT 1 FROM sponsors_partners sp WHERE sp.ideathon_year_id = ideathon_years.id)
          OR EXISTS (SELECT 1 FROM mentors_judges mj WHERE mj.ideathon_year_id = ideathon_years.id)
          OR EXISTS (SELECT 1 FROM ideathon_events ie WHERE ie.ideathon_year_id = ideathon_years.id)
          OR EXISTS (SELECT 1 FROM faqs f WHERE f.ideathon_year_id = ideathon_years.id)
          OR EXISTS (SELECT 1 FROM rules r WHERE r.ideathon_year_id = ideathon_years.id)
        SQL
      )
      .order(year: :desc)
      .first

    with_content || Ideathon.order(year: :desc).first
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
