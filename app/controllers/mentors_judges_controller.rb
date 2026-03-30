class MentorsJudgesController < ApplicationController
  before_action :require_admin, only: [ :destroy, :import ]
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
      ActivityLog.record!(
        user: current_user,
        action: "added",
        message: ActivityLogMessage.for_mentors_judge(@mentors_judge, :added)
      )
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
      ActivityLog.record!(
        user: current_user,
        action: "edited",
        message: ActivityLogMessage.for_mentors_judge(@mentors_judge, :edited, saved_changes: @mentors_judge.saved_changes)
      )
      redirect_to mentors_judges_path, notice: "Mentor/Judge was successfully updated."
    else
      @ideathon_years = Ideathon.pluck(:year).sort.reverse
      render :edit, status: :unprocessable_entity
    end
  end

  def delete
  end

  def destroy
    ActivityLog.record!(
      user: current_user,
      action: "removed",
      message: ActivityLogMessage.for_mentors_judge(@mentors_judge, :removed)
    )
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
      },
      after_create: lambda { |record|
        ActivityLog.record!(
          user: current_user,
          action: "added",
          message: ActivityLogMessage.for_mentors_judge(record, :added)
        )
      }
    ).import

    if result[:failed] > 0
      redirect_to mentors_judges_path, alert: "Imported #{result[:success]}. #{result[:failed]} failed: #{result[:errors].first(3).join(', ')}"
    else
      redirect_to mentors_judges_path, notice: "All #{result[:success]} mentors/judges imported successfully."
    end
  end

  private

  def set_mentors_judge
    @mentors_judge = MentorsJudge.find(params[:id])
  end

  def mentors_judge_params
    params.require(:mentors_judge).permit(:year, :name, :photo_url, :bio, :is_judge)
  end
end
