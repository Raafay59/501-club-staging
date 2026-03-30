class IdeathonsController < ApplicationController
  before_action :require_admin, only: [ :destroy, :import ]
  before_action :set_ideathon, only: [ :show, :edit, :update, :delete, :destroy ]
  before_action :set_ideathon_overview, only: [ :overview ]

  def index
    @ideathons = Ideathon.order(year: :desc)
  end

  def show
  end

  def overview
  end

  def new
    @ideathon = Ideathon.new
  end

  def create
    @ideathon = Ideathon.new(ideathon_params)
    if @ideathon.save
      ActivityLog.record!(
        user: current_user,
        action: "added",
        message: ActivityLogMessage.for_ideathon(@ideathon, :added)
      )
      redirect_to ideathons_path, notice: "Ideathon was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @ideathon.update(ideathon_update_params)
      ActivityLog.record!(
        user: current_user,
        action: "edited",
        message: ActivityLogMessage.for_ideathon(@ideathon, :edited, saved_changes: @ideathon.saved_changes)
      )
      redirect_to ideathons_path, notice: "Ideathon was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def delete
  end

  def destroy
    ActivityLog.record!(
      user: current_user,
      action: "removed",
      message: ActivityLogMessage.for_ideathon(@ideathon, :removed)
    )
    @ideathon.destroy
    redirect_to ideathons_path, notice: "Ideathon was successfully deleted."
  end

  def import
    result = CsvImporter.new(
      file: params[:file],
      model: Ideathon,
      attribute_map: { "year" => :year, "theme" => :theme },
      after_create: lambda { |record|
        ActivityLog.record!(
          user: current_user,
          action: "added",
          message: ActivityLogMessage.for_ideathon(record, :added)
        )
      }
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

  def set_ideathon_overview
    @ideathon = Ideathon.includes(:sponsors_partners, :mentors_judges, :faqs).find(params[:year])
    @sponsors_partners = @ideathon.sponsors_partners.sort_by(&:name)
    @judges = @ideathon.mentors_judges.select(&:is_judge?).sort_by(&:name)
    @faqs = @ideathon.faqs.sort_by(&:id)
    @mentors_judges_with_photos = @ideathon.mentors_judges.select { |mj| mj.photo_url.present? }.sort_by(&:name)
  end

  def ideathon_params
    params.require(:ideathon).permit(:year, :theme)
  end

  def ideathon_update_params
    params.require(:ideathon).permit(:theme)
  end
end
