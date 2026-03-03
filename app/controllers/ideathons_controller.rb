class IdeathonsController < ApplicationController
  before_action :require_admin, only: [ :destroy, :import ]
  before_action :set_ideathon, only: [ :show, :edit, :update, :delete, :destroy ]

  def index
    @ideathons = Ideathon.order(year: :desc)
  end

  def show
  end

  def new
    @ideathon = Ideathon.new
  end

  def create
    @ideathon = Ideathon.new(ideathon_params)
    if @ideathon.save
      redirect_to ideathons_path, notice: "Ideathon was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @ideathon.update(ideathon_update_params)
      redirect_to ideathons_path, notice: "Ideathon was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def delete
  end

  def destroy
    @ideathon.destroy
    redirect_to ideathons_path, notice: "Ideathon was successfully deleted."
  end

  def import
    result = CsvImporter.new(
      file: params[:file],
      model: Ideathon,
      attribute_map: { "year" => :year, "theme" => :theme }
    ).import

    if result[:failed] > 0
      redirect_to ideathons_path, alert: "Imported #{result[:success]} ideathons. #{result[:failed]} failed: #{result[:errors].first(3).join(', ')}"
    else
      redirect_to ideathons_path, notice: "All #{result[:success]} ideathons imported successfully."
    end
  end

  private

  def set_ideathon
    @ideathon = Ideathon.find(params[:year])
  end

  def ideathon_params
    params.require(:ideathon).permit(:year, :theme)
  end

  def ideathon_update_params
    params.require(:ideathon).permit(:theme)
  end
end
