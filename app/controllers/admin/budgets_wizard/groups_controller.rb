class Admin::BudgetsWizard::GroupsController < Admin::BudgetsWizard::BaseController
  include Admin::BudgetGroupsActions

  before_action :load_groups, only: [:index, :create]

  def index
    if single_heading?
      @group = @budget.groups.first_or_initialize("name_#{I18n.locale}" => @budget.name)
    else
      @group = @budget.groups.new
    end
  end

  private

    def groups_index
      if single_heading?
        admin_budgets_wizard_budget_group_headings_path(@budget, @group, url_params)
      else
        admin_budgets_wizard_budget_groups_path(@budget, url_params)
      end
    end

    def new_action
      :index
    end
end
