class RulesController < ClubDashboardController
  before_action :require_admin, only: [ :destroy, :import ]
  before_action :set_rule, only: [ :show, :edit, :update, :delete, :destroy ]

  def index
    @rules = Rule.joins(:ideathon).order(Arel.sql("ideathon_years.year DESC, rules.id ASC"))
  end

  def show
  end

  def new
    @rule = Rule.new
    @ideathon_years = Ideathon.pluck(:year).sort.reverse
  end

  def create
    @rule = Rule.new(rule_params)
    if @rule.save
      redirect_to rules_path, notice: "Rule was successfully created."
    else
      @ideathon_years = Ideathon.pluck(:year).sort.reverse
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @ideathon_years = Ideathon.pluck(:year).sort.reverse
  end

  def update
    if @rule.update(rule_params)
      redirect_to rules_path, notice: "Rule was successfully updated."
    else
      @ideathon_years = Ideathon.pluck(:year).sort.reverse
      render :edit, status: :unprocessable_entity
    end
  end

  def delete
  end

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

    if result[:failed] > 0
      redirect_to rules_path, alert: "Imported #{result[:success]}. #{result[:failed]} failed: #{result[:errors].first(3).join(', ')}"
    else
      redirect_to rules_path, notice: "All #{result[:success]} rules imported successfully."
    end
  end

  private

  def set_rule
    @rule = Rule.find(params[:id])
  end

  def rule_params
    params.require(:rule).permit(:year, :rule_text)
  end
end
