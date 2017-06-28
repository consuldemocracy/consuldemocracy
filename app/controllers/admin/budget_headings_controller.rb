class Admin::BudgetHeadingsController < Admin::BaseController
  include FeatureFlags
  feature_flag :budgets

  def create
    @budget = Budget.find params[:budget_id]
    @budget_group = @budget.groups.find params[:budget_group_id]
    @budget_group.headings.create(budget_heading_params)
    @headings = @budget_group.headings
  end

  private

    def budget_heading_params
      params.require(:budget_heading).permit(:name, :price, :population)
    end

end
