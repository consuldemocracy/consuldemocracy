class Admin::BudgetHeadingsController < Admin::BaseController
  include FeatureFlags
  feature_flag :budgets

  def create
    @budget = Budget.find(params[:budget_id])
    @budget_group = @budget.groups.find(params[:budget_group_id])
    @budget_group.headings.create(budget_heading_params)
    @headings = @budget_group.headings
  end

  def edit
    @budget = Budget.find(params[:budget_id])
    @budget_group = @budget.groups.find(params[:budget_group_id])
    @heading = Budget::Heading.find(params[:id])
  end

  def update
    @budget = Budget.find(params[:budget_id])
    @budget_group = @budget.groups.find(params[:budget_group_id])
    @heading = Budget::Heading.find(params[:id])
    @heading.assign_attributes(budget_heading_params)
    render :edit unless @heading.save
  end

  def destroy
    @heading = Budget::Heading.find(params[:id])
    @heading.destroy
    @budget = Budget.find(params[:budget_id])
    redirect_to admin_budget_path(@budget)
  end

  private

    def budget_heading_params
      params.require(:budget_heading).permit(:name, :price, :population, :latitude, :longitude)
    end

end
