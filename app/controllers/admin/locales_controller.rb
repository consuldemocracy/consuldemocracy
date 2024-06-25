class Admin::LocalesController < Admin::BaseController
  before_action :set_locales_settings
  authorize_resource instance_name: :locales_settings, class: "Setting::LocalesSettings"

  def show
  end

  def update
    @locales_settings.update!(locales_settings_params)

    redirect_to admin_locales_path, notice: t("admin.locales.update.notice")
  end

  private

    def locales_settings_params
      params.require(:setting_locales_settings).permit(allowed_params)
    end

    def allowed_params
      [:default, enabled: []]
    end

    def set_locales_settings
      @locales_settings = Setting::LocalesSettings.new
    end
end
