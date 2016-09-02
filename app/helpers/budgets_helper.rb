module BudgetsHelper

  def budget_phases_select_options
    Budget::VALID_PHASES.map { |ph| [ t("budget.phase.#{ph}"), ph ] }
  end

  def budget_currency_symbol_select_options
    Budget::CURRENCY_SYMBOLS.map { |cs| [ cs, cs ] }
  end

end