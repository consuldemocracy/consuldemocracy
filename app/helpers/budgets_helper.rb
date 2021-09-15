module BudgetsHelper
  def csv_params
    csv_params = params.clone.merge(format: :csv)
    csv_params = csv_params.to_unsafe_h.transform_keys(&:to_sym)
    csv_params.delete(:page)
    csv_params
  end

  def namespaced_budget_investment_path(investment, options = {})
    case namespace
    when "management"
      management_budget_investment_path(investment.budget, investment, options)
    else
      budget_investment_path(investment.budget, investment, options)
    end
  end

  def css_for_ballot_heading(heading)
    current_ballot&.has_lines_in_heading?(heading) ? "is-active" : ""
  end

  def current_ballot
    Budget::Ballot.find_by(user: current_user, budget: @budget)
  end

  def unfeasible_or_unselected_filter
    ["unselected", "unfeasible"].include?(@current_filter)
  end

  def budget_published?(budget)
    budget.published? || current_user&.administrator?
  end

  def budget_subnav_items_for(budget)
    {
      results:    t("budgets.results.link"),
      stats:      t("stats.budgets.link"),
      executions: t("budgets.executions.link")
    }.select { |section, _| can?(:"read_#{section}", budget) }.map do |section, text|
      {
        text: text,
        url:  send("budget_#{section}_path", budget),
        active: controller_name == section.to_s
      }
    end
  end
end
