class Admin::BudgetGroupsController < Admin::BaseController
  include FeatureFlags
  feature_flag :budgets

  def create
    @budget = Budget.find params[:budget_id]
    @budget.groups.create(budget_group_params)
    @groups = @budget.groups.includes(:headings)
  end

  def update
    @group = Budget::Group.by_slug(params[:id]).first
    if @group.generate_slug?
      params[:id] = @group.generate_slug
    end
    @group.update(budget_group_params)
  end

  private

    def budget_group_params
      params.require(:budget_group).permit(:name)
    end

    def load_budget
      @budget = Budget.find_by(slug: params[:budget_id]) || Budget.find_by(id: params[:budget_id])
    end

end
