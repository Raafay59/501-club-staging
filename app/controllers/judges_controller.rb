class JudgesController < ApplicationController
  def index
    @judges = Judge.all
  end

  def show
    @judge = Judge.find(params[:id])
  end

  def new
    @judge = Judge.new
  end

  def create
    @judge = Judge.new(judge_params)

    if @judge.save
      redirect_to judges_path, notice: "Judge was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @judge = Judge.find(params[:id])
  end

  def update
    @judge = Judge.find(params[:id])
    if @judge.update(judge_params)
      redirect_to judges_path, notice: "Judge was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def delete
    @judge = Judge.find(params[:id])
  end

  def destroy
    @judge = Judge.find(params[:id])
    @judge.destroy
    redirect_to judges_path, notice: "Judge was successfully deleted."
  end

  def import
    result = CsvImporter.new(
      file: params[:file],
      model: Judge,
      attribute_map: {
        "Name" => :judge_name,
        "Title" => :judge_title,
        "Bio" => :judge_bio,
        "Ideathon" => :ideathon
      }
    ).import

    if result[:failed] > 0
      redirect_to judges_path, alert: "Some judges were not imported: #{result[:errors].join(", ")}"
    else
      redirect_to judges_path, notice: "Judges imported successfully."
    end
  end

  private

  def judge_params
    params.require(:judge).permit(:judge_name, :judge_title, :judge_bio, :ideathon, :judge_photo)
  end
end
