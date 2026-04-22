class RulesController < ClubDashboardController
     before_action :require_admin, only: [ :destroy, :import ]
     before_action :set_rule, only: [ :show, :edit, :update, :delete, :destroy ]

     def index
          @rules = Rule.joins(:ideathon).order(Arel.sql("ideathon_years.year DESC, rules.id ASC"))
     end

     def show; end

     def new
          @rule = Rule.new
          assign_ideathon_years_for_form!
     end

     def create
          @rule = Rule.new(rule_params)
          if @rule.save
               redirect_to rules_path, notice: "Rule was successfully created."
          else
               assign_ideathon_years_for_form!
               render :new, status: :unprocessable_entity
          end
     end

     def edit
          assign_ideathon_years_for_form!
     end

     def update
          if @rule.update(rule_params)
               redirect_to rules_path, notice: "Rule was successfully updated."
          else
               assign_ideathon_years_for_form!
               render :edit, status: :unprocessable_entity
          end
     end

     def delete; end

     def destroy
          @rule.destroy
          redirect_to rules_path, notice: "Rule was successfully deleted."
     end

     def import
          result = CsvImporter.new(
            file: params[:file],
            model: Rule,
            attribute_map: {
              "year" => :year,
              "rule_text" => :rule_text
            }
          ).import

          redirect_after_csv_import!(
            result: result,
            redirect_path: rules_path,
            failure_alert: ->(r) { "Imported #{r[:success]}. #{r[:failed]} failed: #{r[:errors].first(3).join(', ')}" },
            success_notice: ->(r) { "All #{r[:success]} rules imported successfully." }
          )
     end

  private

       def set_rule
            @rule = Rule.find(params[:id])
       end

       def rule_params
            params.require(:rule).permit(:year, :rule_text)
       end
end
