class Admin::BudgetGroupsController < Admin::BaseController
  include Admin::BudgetGroupsActions

  before_action :load_groups, only: :index

  def index
  end

  def new
    @group = @budget.groups.new
  end

  private

    def groups_index
      admin_budget_groups_path(@budget)
    end

    def new_action
      :new
    end
end
