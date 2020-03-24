class Admin::BudgetsWizard::HeadingsController < Admin::BudgetsWizard::BaseController
  include Admin::BudgetHeadingsActions

  before_action :load_headings, only: [:index, :create]

  def index
    if single_heading?
      @heading = @group.headings.first_or_initialize
    else
      @heading = @group.headings.new
    end
  end

  private

    def headings_index
      if single_heading?
        admin_budgets_wizard_budget_budget_phases_path(@budget, url_params)
      else
        admin_budgets_wizard_budget_group_headings_path(@budget, @group, url_params)
      end
    end

    def load_headings
      @headings = @group.headings.order(:id)
    end

    def new_action
      :index
    end
end
