require 'csv'

class MentorsJudgesController < ApplicationController
  before_action :require_admin, only: [ :destroy, :import, :export ]
  before_action :set_mentors_judge, only: [ :show, :edit, :update, :delete, :destroy ]

  def index
    @mentors_judges = MentorsJudge.order(:year, :name)
  end

  def show
  end

  def new
    @mentors_judge = MentorsJudge.new
    @ideathon_years = Ideathon.pluck(:year).sort.reverse
  end

  def create
    @mentors_judge = MentorsJudge.new(mentors_judge_params)
    if @mentors_judge.save
      redirect_to mentors_judges_path, notice: "Mentor/Judge was successfully created."
    else
      @ideathon_years = Ideathon.pluck(:year).sort.reverse
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @ideathon_years = Ideathon.pluck(:year).sort.reverse
  end

  def update
    if @mentors_judge.update(mentors_judge_params)
      redirect_to mentors_judges_path, notice: "Mentor/Judge was successfully updated."
    else
      @ideathon_years = Ideathon.pluck(:year).sort.reverse
      render :edit, status: :unprocessable_entity
    end
  end

  def delete
  end

  def destroy
    @mentors_judge.destroy
    redirect_to mentors_judges_path, notice: "Mentor/Judge was successfully deleted."
  end

  def import
    result = CsvImporter.new(
      file: params[:file],
      model: MentorsJudge,
      attribute_map: {
        "year" => :year,
        "name" => :name,
        "photo_url" => :photo_url,
        "bio" => :bio,
        "is_judge" => :is_judge
      }
    ).import

    if result[:failed] > 0
      redirect_to mentors_judges_path, alert: "Imported #{result[:success]}. #{result[:failed]} failed: #{result[:errors].first(3).join(', ')}"
    else
      redirect_to mentors_judges_path, notice: "All #{result[:success]} mentors/judges imported successfully."
    end
  end

  def export
    current_year = latest_export_year_for(MentorsJudge)
    judges = MentorsJudge.where(year: current_year, is_judge: true).order(:name)

    if judges.empty?
      redirect_to mentors_judges_path, alert: 'No judges to export'
      return
    end

    csv_data = CSV.generate(headers: true) do |csv|
      csv << [ 'Judge name', 'Photo URL', 'Job title', 'Bio' ]
      judges.each do |judge|
        csv << [ judge.name, judge.photo_url, '', judge.bio ]
      end
    end

    ActivityLog.record_export(model: MentorsJudge, count: judges.count)

    send_data csv_data,
              filename: "judges_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv",
              type: 'text/csv',
              disposition: 'attachment'
  rescue StandardError
    redirect_to mentors_judges_path, alert: 'Export failed. Please try again.'
  end

  private

  def set_mentors_judge
    @mentors_judge = MentorsJudge.find(params[:id])
  end

  def mentors_judge_params
    params.require(:mentors_judge).permit(:year, :name, :photo_url, :bio, :is_judge)
  end

  def latest_export_year_for(model)
    Ideathon.maximum(:year) || model.maximum(:year)
  end
end
