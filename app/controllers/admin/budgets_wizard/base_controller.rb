class Admin::BudgetsWizard::BaseController < Admin::BaseController
  helper_method :budget_mode, :single_heading?, :url_params

  private

    def budget_mode
      params[:mode]
    end

    def single_heading?
      budget_mode == "single"
    end

    def url_params
      budget_mode.present? ? { mode: budget_mode } : {}
    end
end
