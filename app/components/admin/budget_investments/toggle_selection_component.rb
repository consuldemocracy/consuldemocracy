class Admin::BudgetInvestments::ToggleSelectionComponent < ApplicationComponent
  attr_reader :investment
  use_helpers :can?
  delegate :selected?, to: :investment

  def initialize(investment)
    @investment = investment
  end

  private

    def selected_text
      t("admin.budget_investments.index.selected")
    end

    def action
      :toggle_selection
    end

    def path
      toggle_selection_admin_budget_budget_investment_path(
        investment.budget,
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
        "aria-label": label,
        path: path
      }
    end

    def label
      t("admin.actions.label", action: t("admin.actions.select"), name: investment.title)
    end
end
