class Admin::BudgetInvestmentProgressBarsController < Admin::ProgressBarsController
  private

    def progressable
      Budget::Investment.find(params[:budget_investment_id])
    end
end
