class Admin::BudgetsWizard::GroupsController < Admin::BaseController
  include Admin::BudgetGroupsActions

  before_action :load_groups, only: [:index, :create]

  def index
    @group = @budget.groups.new
  end

  private

    def groups_index
      admin_budgets_wizard_budget_groups_path(@budget)
    end

    def new_action
      :index
    end
end
