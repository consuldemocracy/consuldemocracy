class Admin::Budgets::HelpComponent < ApplicationComponent
  attr_reader :i18n_namespace

  def initialize(i18n_namespace)
    @i18n_namespace = i18n_namespace
  end

  def budget_mode
    (helpers.budget_mode if helpers.respond_to?(:budget_mode)).presence || "multiple"
  end

  private

    def text
      if t("admin.budgets.help.#{i18n_namespace}").is_a?(Hash)
        t("admin.budgets.help.#{i18n_namespace}.#{budget_mode}")
      else
        t("admin.budgets.help.#{i18n_namespace}")
      end
    end
end
