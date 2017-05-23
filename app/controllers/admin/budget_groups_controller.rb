class Admin::BudgetGroupsController < Admin::BaseController
  include FeatureFlags
  feature_flag :budgets

  def create
    @budget = Budget.find params[:budget_id]
    @budget.groups.create(budget_group_params)
    @groups = @budget.groups.includes(:headings)
  end

  private

    def budget_group_params
      params.require(:budget_group).permit(:name)
    end

end