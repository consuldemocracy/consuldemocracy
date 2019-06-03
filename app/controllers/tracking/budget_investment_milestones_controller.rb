class Tracking::BudgetInvestmentMilestonesController < Tracking::MilestonesController

  private

    def milestoneable
      Budget::Investment.find(params[:budget_investment_id])
    end
end
