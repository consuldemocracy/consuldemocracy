class Admin::Budgets::HelpComponent < ApplicationComponent
  attr_reader :i18n_namespace

  def initialize(i18n_namespace)
    @i18n_namespace = i18n_namespace
  end

  private

    def text
      t("admin.#{i18n_namespace}.index.help")
    end
end
