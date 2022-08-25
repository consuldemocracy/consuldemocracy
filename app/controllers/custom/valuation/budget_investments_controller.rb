require_dependency Rails.root.join('app', 'controllers', 'valuation', 'budget_investments_controller').to_s

class Valuation::BudgetInvestmentsController < Valuation::BaseController

  def valuate
    if valid_price_params? && @investment.update(valuation_params)
      # we do not want to send any emails
      # if @investment.unfeasible_email_pending?
      #   @investment.send_unfeasible_email
      # end

      Activity.log(current_user, :valuate, @investment)
      notice = t("valuation.budget_investments.notice.valuate")
      redirect_to valuation_budget_budget_investment_path(@budget, @investment), notice: notice
    else
      render action: :edit
    end
  end

end
