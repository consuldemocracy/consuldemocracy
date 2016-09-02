module BudgetHelper
  def format_price(budget, number)
    number_to_currency(number,
                       precision: 0,
                       locale: I18n.default_locale,
                       unit: budget.currency_symbol)
  end

  def heading_name(heading)
    heading.present? ? heading.name : t("budget.headings.none")
  end

  def namespaced_budget_investment_path(investment, options={})
    @namespaced_budget_investment_path ||= namespace
    options[:budget_id] ||= investment.budget.id
    case @namespace_budget_investment_path
    when "management"
      management_budget_investment_path(investment, options)
    else
      budget_investment_path(investment, options)
    end
  end
end
