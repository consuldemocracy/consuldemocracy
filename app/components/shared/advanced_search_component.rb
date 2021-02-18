class Shared::AdvancedSearchComponent < ApplicationComponent
  include SDG::OptionsForSelect

  private

    def advanced_search
      params[:advanced_search] || {}
    end

    def official_level_search_options
      options_for_select((1..5).map { |i| [setting["official_level_#{i}_name"], i] },
                         advanced_search[:official_level])
    end

    def date_range_options
      options_for_select([
        [t("shared.advanced_search.date_1"), 1],
        [t("shared.advanced_search.date_2"), 2],
        [t("shared.advanced_search.date_3"), 3],
        [t("shared.advanced_search.date_4"), 4],
        [t("shared.advanced_search.date_5"), "custom"]],
        selected_date_range)
    end

    def selected_date_range
      custom_date_range? ? "custom" : advanced_search[:date_min]
    end

    def custom_date_range?
      advanced_search[:date_max].present?
    end

    def goal_options
      super(advanced_search[:goal])
    end

    def target_options
      super(advanced_search[:target])
    end

    def sdg?
      SDG::ProcessEnabled.new(controller_path).enabled?
    end
end
