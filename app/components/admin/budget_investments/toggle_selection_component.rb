class Admin::BudgetInvestments::ToggleSelectionComponent < ApplicationComponent
  include Admin::SwitchText
  attr_reader :investment
  delegate :can?, to: :controller

  def initialize(investment)
    @investment = investment
  end

  private

    def budget
      investment.budget
    end

    def checked?
      investment.selected?
    end

    def path
      toggle_selection_admin_budget_budget_investment_path(
        budget,
        investment,
        filter: params[:filter],
        sort_by: params[:sort_by],
        min_total_supports: params[:min_total_supports],
        max_total_supports: params[:max_total_supports],
        advanced_filters: params[:advanced_filters],
        page: params[:page]
      )
    end

    def options
      {
        method: :patch,
        remote: true,
        class: "investment-toggle-selection",
        "aria-label": label,
        "aria-pressed": checked?
      }
    end

    def label
      # TODO: Use I18n
      "#{t("admin.budget_investments.index.selected")} #{investment.title}"
    end
end
