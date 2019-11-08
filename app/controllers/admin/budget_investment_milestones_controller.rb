class Admin::BudgetInvestmentMilestonesController < Admin::MilestonesController
  private

    def milestoneable
      Budget::Investment.find(params[:budget_investment_id])
    end
end
