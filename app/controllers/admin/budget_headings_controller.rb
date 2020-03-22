class Admin::BudgetHeadingsController < Admin::BaseController
  include Admin::BudgetHeadingsActions

  def index
  end

  def new
    @heading = @group.headings.new
  end

  private

    def headings_index
      admin_budget_group_headings_path(@budget, @group)
    end

    def new_action
      :new
    end
end
