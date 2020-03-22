class Admin::BudgetsWizard::HeadingsController < Admin::BaseController
  include Admin::BudgetHeadingsActions

  before_action :load_headings, only: [:index, :create]

  def index
    @heading = @group.headings.new
  end

  private

    def headings_index
      admin_budgets_wizard_budget_group_headings_path(@budget, @group)
    end

    def new_action
      :index
    end
end
