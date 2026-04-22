require "csv"

class MentorsJudgesController < ClubDashboardController
     before_action :require_admin, only: [ :destroy, :import, :export ]
     before_action :set_mentors_judge, only: [ :show, :edit, :update, :delete, :destroy ]

     def index
          @mentors_judges = MentorsJudge.joins(:ideathon).order(Arel.sql("ideathon_years.year DESC, mentors_judges.name ASC"))
     end

     def show; end

     def new
          @mentors_judge = MentorsJudge.new
          assign_ideathon_years_for_form!
     end

     def create
          @mentors_judge = MentorsJudge.new(mentors_judge_params)
          normalize_optional_url_from_params!(@mentors_judge, root_key: :mentors_judge, attribute: :photo_url, include_flag: :include_photo)
          if @mentors_judge.save
               redirect_to mentors_judges_path, notice: "Mentor/Judge was successfully created."
          else
               assign_ideathon_years_for_form!
               render :new, status: :unprocessable_entity
          end
     end

     def edit
          assign_ideathon_years_for_form!
     end

     def update
          @mentors_judge.assign_attributes(mentors_judge_params)
          normalize_optional_url_from_params!(@mentors_judge, root_key: :mentors_judge, attribute: :photo_url, include_flag: :include_photo)

          if @mentors_judge.save
               redirect_to mentors_judges_path, notice: "Mentor/Judge was successfully updated."
          else
               assign_ideathon_years_for_form!
               render :edit, status: :unprocessable_entity
          end
     end

     def delete; end

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
              "job_title" => :job_title,
              "photo_url" => :photo_url,
              "bio" => :bio,
              "is_judge" => :is_judge
            }
          ).import

          redirect_after_csv_import!(
            result: result,
            redirect_path: mentors_judges_path,
            failure_alert: ->(r) { "Imported #{r[:success]}. #{r[:failed]} failed: #{r[:errors].first(3).join(', ')}" },
            success_notice: ->(r) { "All #{r[:success]} mentors/judges imported successfully." }
          )
     end

     def export
          current_year = latest_export_year_for(MentorsJudge)
          return redirect_to(mentors_judges_path, alert: "No judges to export") unless current_year

          judges = MentorsJudge.joins(:ideathon).where(ideathon_years: { year: current_year }, is_judge: true).order(:name)
          return redirect_to(mentors_judges_path, alert: "No judges to export") if judges.empty?

          csv_data = CSV.generate(headers: true) do |csv|
               csv << [ "Judge name", "Photo URL", "Job title", "Bio" ]
               judges.each { |judge| csv << [ judge.name, judge.photo_url, judge.job_title, judge.bio ] }
          end

          ActivityLog.record_export(model: MentorsJudge, count: judges.count)

          send_data csv_data,
                    filename: "judges_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv",
                    type: "text/csv",
                    disposition: "attachment"
     rescue StandardError
          redirect_to mentors_judges_path, alert: "Export failed. Please try again."
     end

  private

       def set_mentors_judge
            @mentors_judge = MentorsJudge.find(params[:id])
       end

       def mentors_judge_params
            params.require(:mentors_judge).permit(:year, :name, :job_title, :photo_url, :bio, :is_judge)
       end

       def latest_export_year_for(_model)
            MentorsJudge
              .joins(:ideathon)
              .where(is_judge: true)
              .maximum("ideathon_years.year")
       end
end
