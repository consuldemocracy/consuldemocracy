module BudgetInvestmentsHelper
  def budget_investments_sorting_options
    Budget::Investment::SORTING_OPTIONS.map { |so| [t("admin.budget_investments.index.sort_by.#{so}"), so] }
  end
end
