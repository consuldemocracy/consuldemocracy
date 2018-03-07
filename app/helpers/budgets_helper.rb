module BudgetsHelper

  def show_links_to_budget_investments(budget)
    ['balloting', 'reviewing_ballots', 'finished'].include? budget.phase
  end

  def heading_name_and_price_html(heading, budget)
    content_tag :div do
      concat(heading.name + ' ')
      concat(content_tag(:span, budget.formatted_heading_price(heading)))
    end
  end

  def csv_params
    csv_params = params.clone.merge(format: :csv).symbolize_keys
    csv_params.delete(:page)
    csv_params
  end

  def budget_phases_select_options
    Budget::Phase::PHASE_KINDS.map { |ph| [ t("budgets.phase.#{ph}"), ph ] }
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

  def display_budget_countdown?(budget)
    budget.balloting?
  end

  def css_for_ballot_heading(heading)
    return '' if current_ballot.blank?
    current_ballot.has_lines_in_heading?(heading) ? 'active' : ''
  end

  def current_ballot
    Budget::Ballot.where(user: current_user, budget: @budget).first
  end

  def investment_tags_select_options(budget)
    Budget::Investment.by_budget(budget).tags_on(:valuation).order(:name).select(:name).distinct
  end

  def budget_published?(budget)
    !budget.drafting? || current_user&.administrator?
  end

  def current_budget_map_locations
    MapLocation.where(investment_id: current_budget.investments).map { |l| l.json_data }
  end
end
