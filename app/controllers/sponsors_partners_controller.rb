require "csv"

class SponsorsPartnersController < ClubDashboardController
     before_action :require_admin, only: [ :destroy, :import, :export ]
     before_action :set_sponsors_partner, only: [ :show, :edit, :update, :delete, :destroy ]

     def index
          @sponsors_partners = SponsorsPartner.joins(:ideathon).order(Arel.sql("ideathon_years.year DESC, sponsors_partners.name ASC"))
     end

     def show; end

     def new
          @sponsors_partner = SponsorsPartner.new
          assign_ideathon_years_for_form!
     end

     def create
          @sponsors_partner = SponsorsPartner.new(sponsors_partner_params)
          normalize_optional_url_from_params!(@sponsors_partner, root_key: :sponsors_partner, attribute: :logo_url, include_flag: :include_logo)
          if @sponsors_partner.save
               redirect_to sponsors_partners_path, notice: "Sponsor/Partner was successfully created."
          else
               assign_ideathon_years_for_form!
               render :new, status: :unprocessable_entity
          end
     end

     def edit
          assign_ideathon_years_for_form!
     end

     def update
          @sponsors_partner.assign_attributes(sponsors_partner_params)
          normalize_optional_url_from_params!(@sponsors_partner, root_key: :sponsors_partner, attribute: :logo_url, include_flag: :include_logo)

          if @sponsors_partner.save
               redirect_to sponsors_partners_path, notice: "Sponsor/Partner was successfully updated."
          else
               assign_ideathon_years_for_form!
               render :edit, status: :unprocessable_entity
          end
     end

     def delete; end

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
              "job_title" => :job_title,
              "logo_url" => :logo_url,
              "blurb" => :blurb,
              "is_sponsor" => :is_sponsor
            }
          ).import

          redirect_after_csv_import!(
            result: result,
            redirect_path: sponsors_partners_path,
            failure_alert: ->(r) { "Imported #{r[:success]}. #{r[:failed]} failed: #{r[:errors].first(3).join(', ')}" },
            success_notice: ->(r) { "All #{r[:success]} sponsors/partners imported successfully." }
          )
     end

     def export
          current_year = latest_export_year_for(SponsorsPartner)
          return redirect_to(sponsors_partners_path, alert: "No sponsors to export") unless current_year

          sponsors = SponsorsPartner.joins(:ideathon).where(ideathon_years: { year: current_year }, is_sponsor: true).order(:name)
          return redirect_to(sponsors_partners_path, alert: "No sponsors to export") if sponsors.empty?

          csv_data = CSV.generate(headers: true) do |csv|
               csv << [ "Sponsor name", "Logo URL", "Job title", "Bio" ]
               sponsors.each { |sponsor| csv << [ sponsor.name, sponsor.logo_url, sponsor.job_title, sponsor.blurb ] }
          end

          ActivityLog.record_export(model: SponsorsPartner, count: sponsors.count)

          send_data csv_data,
                    filename: "sponsors_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv",
                    type: "text/csv",
                    disposition: "attachment"
     rescue StandardError
          redirect_to sponsors_partners_path, alert: "Export failed. Please try again."
     end

  private

       def set_sponsors_partner
            @sponsors_partner = SponsorsPartner.find(params[:id])
       end

       def sponsors_partner_params
            params.require(:sponsors_partner).permit(:year, :name, :job_title, :logo_url, :blurb, :is_sponsor)
       end

       def latest_export_year_for(_model)
            SponsorsPartner
              .joins(:ideathon)
              .where(is_sponsor: true)
              .maximum("ideathon_years.year")
       end
end
