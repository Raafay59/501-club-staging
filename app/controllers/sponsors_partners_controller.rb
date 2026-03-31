class SponsorsPartnersController < ApplicationController
  before_action :require_admin, only: [ :destroy, :import ]
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

  private

  def set_sponsors_partner
    @sponsors_partner = SponsorsPartner.find(params[:id])
  end

  def sponsors_partner_params
    params.require(:sponsors_partner).permit(:year, :name, :logo_url, :blurb, :is_sponsor)
  end
end
