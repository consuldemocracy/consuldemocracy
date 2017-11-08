class Admin::BudgetHeadingsController < Admin::BaseController
  include FeatureFlags
  feature_flag :budgets

  before_action :load_budget
  before_action :load_group

  def create
    @budget_group.headings.create(budget_heading_params)
    @headings = @budget_group.headings
  end

  private

    def budget_heading_params
      params.require(:budget_heading).permit(:name, :price, :population)
    end

    def load_budget
      @budget = Budget.find_by(slug: params[:budget_id]) || Budget.find_by(id: params[:budget_id])
    end

    def load_group
      @budget_group = @budget.groups.find_by(slug: params[:budget_group_id]) || @budget.groups.find_by(id: params[:budget_group_id])
    end
end
