module BudgetInvestmentsHelper
  def budget_investments_sorting_options
    Budget::Investment::SORTING_OPTIONS.map do |so|
      [t("admin.budget_investments.index.sort_by.#{so}"), so]
    end
  end

  def budget_investments_advanced_filters(params)
    params.map { |af| t("admin.budget_investments.index.filters.#{af}") }.join(', ')
  end
end
