class FaqsController < ClubDashboardController
     before_action :require_admin, only: [ :destroy, :import ]
     before_action :set_faq, only: [ :show, :edit, :update, :delete, :destroy ]

     def index
          @faqs = Faq.joins(:ideathon).order(Arel.sql("ideathon_years.year DESC, faqs.id ASC"))
     end

     def show; end

     def new
          @faq = Faq.new
          assign_ideathon_years_for_form!
     end

     def create
          @faq = Faq.new(faq_params)
          if @faq.save
               redirect_to faqs_path, notice: "FAQ was successfully created."
          else
               assign_ideathon_years_for_form!
               render :new, status: :unprocessable_entity
          end
     end

     def edit
          assign_ideathon_years_for_form!
     end

     def update
          if @faq.update(faq_params)
               redirect_to faqs_path, notice: "FAQ was successfully updated."
          else
               assign_ideathon_years_for_form!
               render :edit, status: :unprocessable_entity
          end
     end

     def delete; end

     def destroy
          @faq.destroy
          redirect_to faqs_path, notice: "FAQ was successfully deleted."
     end

     def import
          result = CsvImporter.new(
            file: params[:file],
            model: Faq,
            attribute_map: {
              "year" => :year,
              "question" => :question,
              "answer" => :answer
            }
          ).import

          redirect_after_csv_import!(
            result: result,
            redirect_path: faqs_path,
            failure_alert: ->(r) { "Imported #{r[:success]}. #{r[:failed]} failed: #{r[:errors].first(3).join(', ')}" },
            success_notice: ->(r) { "All #{r[:success]} FAQs imported successfully." }
          )
     end

  private

       def set_faq
            @faq = Faq.find(params[:id])
       end

       def faq_params
            params.require(:faq).permit(:year, :question, :answer)
       end
end
