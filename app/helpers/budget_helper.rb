module BudgetHelper
  def format_price(budget, number)
    number_to_currency(number,
                       precision: 0,
                       locale: I18n.default_locale,
                       unit: budget.currency_symbol)
  end
end
