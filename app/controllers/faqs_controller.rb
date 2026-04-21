class FaqsController < ClubDashboardController
     before_action :require_admin, only: [ :destroy, :import ]
     before_action :set_faq, only: [ :show, :edit, :update, :delete, :destroy ]

     def index
          @faqs = Faq.joins(:ideathon).order(Arel.sql("ideathon_years.year DESC, faqs.id ASC"))
     end

     def show; end

     def new
          @faq = Faq.new
          @ideathon_years = Ideathon.where.not(year: nil).pluck(:year).sort.reverse
     end

     def create
          @faq = Faq.new(faq_params)
          if @faq.save
               redirect_to faqs_path, notice: "FAQ was successfully created."
          else
               @ideathon_years = Ideathon.where.not(year: nil).pluck(:year).sort.reverse
               render :new, status: :unprocessable_entity
          end
     end

     def edit
          @ideathon_years = Ideathon.where.not(year: nil).pluck(:year).sort.reverse
     end

     def update
          if @faq.update(faq_params)
               redirect_to faqs_path, notice: "FAQ was successfully updated."
          else
               @ideathon_years = Ideathon.where.not(year: nil).pluck(:year).sort.reverse
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

          if result[:failed] > 0
               redirect_to faqs_path, alert: "Imported #{result[:success]}. #{result[:failed]} failed: #{result[:errors].first(3).join(', ')}"
          else
               redirect_to faqs_path, notice: "All #{result[:success]} FAQs imported successfully."
          end
     end

  private

       def set_faq
            @faq = Faq.find(params[:id])
       end

       def faq_params
            params.require(:faq).permit(:year, :question, :answer)
       end
end
