module SearchHelper

  def official_level_search_options
    options_for_select((1..5).map{ |i| [setting["official_level_#{i}_name"], i] },
                       params[:advanced_search].try(:[], :official_level))
  end

  def budget_phases_search_options
    selected = params[:advanced_search].nil? ? '' : params[:advanced_search][:budget_phase]
    options_for_select([
      [t("budgets.phase.accepting"), 'accepting'],
      [t("budgets.phase.reviewing"), 'reviewing'],
      [t("budgets.phase.selecting"), 'selecting'],
      [t("budgets.phase.valuating"), 'valuating'],
      [t("budgets.phase.balloting"), 'balloting'],
      [t("budgets.phase.reviewing_ballots"), 'reviewing_ballots'],
      [t("budgets.phase.finished"), 'finished']],
      selected)
  end

  def date_range_options
    options_for_select([
      [t("shared.advanced_search.date_1"), 1],
      [t("shared.advanced_search.date_2"), 2],
      [t("shared.advanced_search.date_3"), 3],
      [t("shared.advanced_search.date_4"), 4],
      [t("shared.advanced_search.date_5"), 'custom']],
      selected_date_range)
  end

  def selected_date_range
    custom_date_range? ? 'custom' : params[:advanced_search].try(:[], :date_min)
  end

  def custom_date_range?
    params[:advanced_search].try(:[], :date_max).present?
  end

end
