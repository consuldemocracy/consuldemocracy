module SearchHelper

  def official_level_options
    options_for_select([
      [t("shared.advanced_search.author_type_1"), 1],
      [t("shared.advanced_search.author_type_2"), 2],
      [t("shared.advanced_search.author_type_3"), 3],
      [t("shared.advanced_search.author_type_4"), 4],
      [t("shared.advanced_search.author_type_5"), 5]],
      params[:official_level])
  end

  def date_range_options
    options_for_select([
      [t("shared.advanced_search.date_1"), 24.hours.ago],
      [t("shared.advanced_search.date_2"), 7.days.ago],
      [t("shared.advanced_search.date_3"), 30.days.ago],
      [t("shared.advanced_search.date_4"), 365.days.ago],
      [t("shared.advanced_search.date_5"), 'custom']],
      params[:date_range])
  end

end