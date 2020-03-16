class Admin::Budgets::HelpComponent < ApplicationComponent

  private

    def i18n_namespace
      "admin.budgets.index"
    end

    def text
      t("#{i18n_namespace}.help")
    end
end
