class Admin::SettingsController < Admin::BaseController

  def index
    all_settings = Setting.all.group_by { |setting| setting.type }
    @configuration_settings = all_settings["configuration"]
    @feature_settings = all_settings["feature"]
    @participation_processes_settings = all_settings["process"]
    @map_configuration_settings = all_settings["map"]
  end

  def update
    @setting = Setting.find(params[:id])
    @setting.update(settings_params)
    redirect_to request.referer, notice: t("admin.settings.flash.updated")
  end

  def update_map
    Setting["map.latitude"] = params[:latitude].to_f
    Setting["map.longitude"] = params[:longitude].to_f
    Setting["map.zoom"] = params[:zoom].to_i
    redirect_to admin_settings_path, notice: t("admin.settings.index.map.flash.update")
  end

  private

    def settings_params
      params.require(:setting).permit(:value)
    end

end
