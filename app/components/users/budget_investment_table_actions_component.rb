class Users::BudgetInvestmentTableActionsComponent < ApplicationComponent
  attr_reader :investment
  use_helpers :can?

  def initialize(investment)
    @investment = investment
  end

  private

    def edit_link
      link_to t("shared.edit"),
              edit_budget_investment_path(investment.budget, investment),
              class: "button hollow"
    end

    def destroy_button
      button_to t("shared.delete"),
                budget_investment_path(investment.budget, investment),
                method: :delete,
                class: "button hollow alert",
                data: { confirm: t("users.show.delete_alert") }
    end
end
