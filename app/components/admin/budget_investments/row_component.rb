class Admin::BudgetInvestments::RowComponent < ApplicationComponent
  attr_reader :investment

  def initialize(investment)
    @investment = investment
  end

  private

    def budget
      investment.budget
    end

    def investment_path
      admin_budget_budget_investment_path(budget_id: budget.id,
                                          id: investment.id,
                                          params: Budget::Investment.filter_params(params).to_h)
    end

    def administrator_info
      if investment.administrator.present?
        tag.span(investment.administrator.description_or_name,
                 title: t("admin.budget_investments.index.assigned_admin"))
      else
        t("admin.budget_investments.index.no_admin_assigned")
      end
    end

    def valuators_info
      valuators = [investment.assigned_valuation_groups, investment.assigned_valuators].compact

      if valuators.present?
        valuators.join(", ")
      else
        t("admin.budget_investments.index.no_valuators_assigned")
      end
    end
end
