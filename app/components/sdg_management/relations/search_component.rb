class SDGManagement::Relations::SearchComponent < ApplicationComponent
  include SDG::OptionsForSelect
  attr_reader :label

  def initialize(label:)
    @label = label
  end

  private

    def goal_label
      t("admin.shared.search.advanced_filters.sdg_goals.label")
    end

    def goal_blank_option
      t("admin.shared.search.advanced_filters.sdg_goals.all")
    end

    def target_label
      t("admin.shared.search.advanced_filters.sdg_targets.label")
    end

    def target_blank_option
      t("admin.shared.search.advanced_filters.sdg_targets.all")
    end

    def goal_options
      super(params[:goal_code])
    end

    def target_options
      super(params[:target_code])
    end
end
