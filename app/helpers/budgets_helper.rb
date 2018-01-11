module BudgetsHelper

  def csv_params
    csv_params = params.clone.merge(format: :csv).symbolize_keys
    csv_params.delete(:page)
    csv_params
  end

  def investment_selected_link(investment)
    options = investment_selected_link_options(investment)
    path = toggle_selection_admin_budget_budget_investment_path(@budget,
           investment, filter: params[:filter], page: params[:page])
    link_options = {method: :patch, remote: true, class: options[:link_class]}
    link_to options[:text], path, link_options
  end

  def investment_selected_link_options(investment)
    if investment.selected?
      {link_class: "button small expanded",
       text: t("admin.budget_investments.index.selected") }
    elsif investment.feasible? && investment.valuation_finished?
      {link_class: "button small hollow expanded",
       text: t("admin.budget_investments.index.select")}
    else
      {}
    end
  end

  def budget_phases_select_options
    Budget::PHASES.map { |ph| [ t("budgets.phase.#{ph}"), ph ] }
  end

  def budget_currency_symbol_select_options
    Budget::CURRENCY_SYMBOLS.map { |cs| [ cs, cs ] }
  end

  def namespaced_budget_investment_path(investment, options = {})
    case namespace
    when "management/budgets"
      management_budget_investment_path(investment.budget, investment, options)
    else
      budget_investment_path(investment.budget, investment, options)
    end
  end

  def namespaced_budget_investment_vote_path(investment, options = {})
    case namespace
    when "management/budgets"
      vote_management_budget_investment_path(investment.budget, investment, options)
    else
      vote_budget_investment_path(investment.budget, investment, options)
    end
  end

  def css_for_ballot_heading(heading)
    return '' if current_ballot.blank?
    current_ballot.has_lines_in_heading?(heading) ? 'active' : ''
  end

  def current_ballot
    Budget::Ballot.where(user: current_user, budget: @budget).first
  end

  def investment_tags_select_options
    Budget::Investment.tags_on(:valuation).order(:name).select(:name).distinct
  end

  def budget_published?(budget)
    !budget.drafting? || current_user&.administrator?
  end

  def display_support_alert?(investment)
    current_user &&
    !current_user.voted_in_group?(investment.group) &&
    investment.group.headings.count > 1
  end

end
