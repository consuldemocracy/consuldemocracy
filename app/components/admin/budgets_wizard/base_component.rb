class Admin::BudgetsWizard::BaseComponent < ApplicationComponent
  use_helpers :single_heading?, :url_params

  def budget_mode
    helpers.budget_mode || "multiple"
  end
end
