require "csv"

class SponsorsPartnersController < ApplicationController
  before_action :require_admin, only: [ :destroy, :import, :export ]
  before_action :set_sponsors_partner, only: [ :show, :edit, :update, :delete, :destroy ]

  def index
    @sponsors_partners = SponsorsPartner.order(:year, :name)
  end

  def show
    @sponsors_partner = SponsorsPartner.find(params[:id])
  end

  def new
    @sponsors_partner = SponsorsPartner.new
    @ideathon_years = Ideathon.pluck(:year).sort.reverse
  end

  def create
    @sponsors_partner = SponsorsPartner.new(sponsors_partner_params)
    if @sponsors_partner.save
      redirect_to sponsors_partners_path, notice: "Sponsor/Partner was successfully created."
    else
      @ideathon_years = Ideathon.pluck(:year).sort.reverse
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @ideathon_years = Ideathon.pluck(:year).sort.reverse
  end

  def update
    if @sponsors_partner.update(sponsors_partner_params)
      redirect_to sponsors_partners_path, notice: "Sponsor/Partner was successfully updated."
    else
      @ideathon_years = Ideathon.pluck(:year).sort.reverse
      render :edit, status: :unprocessable_entity
    end
  end

  def delete
  end

  def destroy
    @sponsors_partner.destroy
    redirect_to sponsors_partners_path, notice: "Sponsor/Partner was successfully deleted."
  end

  def import
    result = CsvImporter.new(
      file: params[:file],
      model: SponsorsPartner,
      attribute_map: {
        "year" => :year,
        "name" => :name,
        "job_title" => :job_title,
        "logo_url" => :logo_url,
        "blurb" => :blurb,
        "is_sponsor" => :is_sponsor
      }
    ).import

    if result[:failed] > 0
      redirect_to sponsors_partners_path, alert: "Imported #{result[:success]}. #{result[:failed]} failed: #{result[:errors].first(3).join(', ')}"
    else
      redirect_to sponsors_partners_path, notice: "All #{result[:success]} sponsors/partners imported successfully."
    end
  end

  def export
    current_year = latest_export_year_for(SponsorsPartner)
    sponsors = SponsorsPartner.where(year: current_year, is_sponsor: true).order(:name)

    if sponsors.empty?
      redirect_to sponsors_partners_path, alert: "No sponsors to export"
      return
    end

    csv_data = CSV.generate(headers: true) do |csv|
      csv << [ "Sponsor name", "Logo URL", "Job title", "Bio" ]
      sponsors.each do |sponsor|
        csv << [ sponsor.name, sponsor.logo_url, sponsor.job_title, sponsor.blurb ]
      end
    end

    ActivityLog.record_export(model: SponsorsPartner, count: sponsors.count)

    send_data csv_data,
              filename: "sponsors_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv",
              type: "text/csv",
              disposition: "attachment"
  rescue StandardError
    redirect_to sponsors_partners_path, alert: "Export failed. Please try again."
  end

  private

  def set_sponsors_partner
    @sponsors_partner = SponsorsPartner.find(params[:id])
  end

  def sponsors_partner_params
    params.require(:sponsors_partner).permit(:year, :name, :job_title, :logo_url, :blurb, :is_sponsor)
  end

  def latest_export_year_for(model)
    Ideathon.maximum(:year) || model.maximum(:year)
  end
end
