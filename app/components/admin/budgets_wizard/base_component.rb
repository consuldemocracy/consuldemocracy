class Admin::BudgetsWizard::BaseComponent < ApplicationComponent
  delegate :single_heading?, :url_params, to: :helpers
end
