class Admin::BudgetHeadingsController < Admin::BaseController
  include Admin::BudgetHeadingsActions

  def new
    @heading = @group.headings.new
  end

  private

    def headings_index
      admin_budget_path(@budget)
    end

    def new_action
      :new
    end
end
