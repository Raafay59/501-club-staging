class IdeathonsController < ClubDashboardController
     before_action :require_admin, only: [ :destroy, :import ]
     before_action :set_ideathon, only: [ :show, :edit, :update, :delete, :destroy ]
     before_action :set_ideathon_overview, only: [ :overview ]

     def index
          @ideathons = Ideathon.order(year: :desc)
     end

     def show; end

     def overview; end

     def new
          @ideathon = Ideathon.new
     end

     def create
          @ideathon = Ideathon.new(ideathon_params)
          ActiveRecord::Base.transaction do
               @ideathon.save!
               activate_year_exclusively!(@ideathon) if @ideathon.is_active?
          end
          redirect_to ideathons_path, notice: "Ideathon was successfully created."
     rescue ActiveRecord::RecordInvalid
          render :new, status: :unprocessable_entity
     end

     def edit; end

     def update
          ActiveRecord::Base.transaction do
               @ideathon.update!(ideathon_update_params)
               activate_year_exclusively!(@ideathon) if @ideathon.is_active?
          end
          redirect_to ideathons_path, notice: "Ideathon was successfully updated."
     rescue ActiveRecord::RecordInvalid
          render :edit, status: :unprocessable_entity
     end

     def delete; end

     def destroy
          if @ideathon.destroy
               redirect_to ideathons_path, notice: "Ideathon was successfully deleted."
          else
               message = @ideathon.errors.full_messages.to_sentence.presence || "Unable to delete ideathon."
               redirect_to ideathons_path, alert: message
          end
     rescue ActiveRecord::InvalidForeignKey => e
          Rails.logger.error("Ideathon delete FK violation: #{e.message}")
          redirect_to ideathons_path, alert: "Unable to delete ideathon because related records still exist."
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
            @ideathon = Ideathon.find_by!(year: params[:year].to_i)
       end

       def set_ideathon_overview
            begin
                 @ideathon = Ideathon.includes(:sponsors_partners, :mentors_judges, :faqs).find_by!(year: params[:year].to_i)
            rescue ActiveRecord::RecordNotFound
                 redirect_to ideathons_path, alert: "Ideathon year #{params[:year]} was not found."
                 return
            end

            @sponsors_partners = @ideathon.sponsors_partners.sort_by(&:name)
            @judges = @ideathon.mentors_judges.select(&:is_judge?).sort_by(&:name)
            @faqs = @ideathon.faqs.sort_by(&:id)
            @mentors_judges_with_photos = @ideathon.mentors_judges.select { |mj| mj.photo_url.present? }.sort_by(&:name)
       end

       def ideathon_params
            params.require(:ideathon).permit(:year, :theme, :name, :description, :location, :start_date, :end_date, :is_active)
       end

       def ideathon_update_params
            params.require(:ideathon).permit(:theme, :name, :description, :location, :start_date, :end_date, :is_active)
       end

       def activate_year_exclusively!(active_ideathon)
            # Keep this as a bulk update to avoid logging noise on every historical year,
            # but still update timestamps for accurate "recently updated" ordering.
            Ideathon.where.not(id: active_ideathon.id).where(is_active: true)
                    .update_all(is_active: false, updated_at: Time.current)
       end
end
