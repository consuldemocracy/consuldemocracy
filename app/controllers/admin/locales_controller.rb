class Admin::LocalesController < Admin::BaseController
  def show
    @enabled_locales = Setting.enabled_locales
    @default_locale = Setting.default_locale
  end

  def update
    Setting.transaction do
      Setting["locales.default"] = params["default_locale"]
      Setting["locales.enabled"] = [params["default_locale"], *params["enabled_locales"]].join(" ")
    end

    redirect_to admin_locales_path, notice: t("admin.locales.update.notice")
  end
end
