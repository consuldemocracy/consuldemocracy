class Admin::Budgets::HeadingModeComponent < ApplicationComponent
  private

    def i18n_namespace
      "admin.budgets_wizard.heading_mode"
    end

    def modes
      %w[single multiple]
    end
end
