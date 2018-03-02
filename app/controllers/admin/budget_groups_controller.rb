class Admin::BudgetGroupsController < Admin::BaseController
  include FeatureFlags
  feature_flag :budgets
  before_action :load_budget

  def create
    @budget.groups.create(budget_group_params)
    @groups = @budget.groups.includes(:headings)
  end

  private

    def budget_group_params
      params.require(:budget_group).permit(:name)
    end

    def load_budget
      @budget = Budget.find_by(slug: params[:budget_id]) || Budget.find_by(id: params[:budget_id])
    end

end