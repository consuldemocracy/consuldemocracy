class Admin::BudgetGroupsController < Admin::BaseController
  include Admin::BudgetGroupsActions

  def new
    @group = @budget.groups.new
  end

  private

    def groups_index
      admin_budget_path(@budget)
    end

    def new_action
      :new
    end
end
