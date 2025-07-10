require_dependency Rails.root.join("app", "controllers", "admin", "budgets_controller").to_s

class Admin::BudgetsController < Admin::BaseController
  private

    def budget_params
      descriptions = Budget::Phase::PHASE_KINDS.map { |p| "description_#{p}" }.map(&:to_sym)
      valid_attributes = [:phase,
                          :currency_symbol,
                          :result_text,
                          administrator_ids: [],
                          valuator_ids: []
      ] + descriptions
      params.require(:budget).permit(*valid_attributes, *report_attributes, translation_params(Budget))
    end
end
