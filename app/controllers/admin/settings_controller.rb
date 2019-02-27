class Admin::SettingsController < Admin::BaseController

  def index
    all_settings = Setting.all.group_by { |s| s.type }
    @settings = all_settings["common"].reject { |setting| hidden_settings.include?(setting.key)}
    @feature_flags = all_settings['feature']
  end

  def update
    @setting = Setting.find(params[:id])
    @setting.update(settings_params)
    redirect_to request.referer, notice: t("admin.settings.flash.updated")
  end

  def update_map
    Setting["map_latitude"] = params[:latitude].to_f
    Setting["map_longitude"] = params[:longitude].to_f
    Setting["map_zoom"] = params[:zoom].to_i
    redirect_to admin_settings_path, notice: t("admin.settings.index.map.flash.update")
  end

  private

    def settings_params
      params.require(:setting).permit(:value)
    end

    def hidden_settings
      ["place_name",
       "blog_url",
       "transparency_url",
       "opendata_url",
       "banner-style.banner-style-one",
       "banner-style.banner-style-two",
       "banner-style.banner-style-three",
       "banner-img.banner-img-one",
       "banner-img.banner-img-two",
       "banner-img.banner-img-three",
       "proposal_improvement_path"]
    end

end
