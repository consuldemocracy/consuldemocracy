class Admin::SettingsController < Admin::BaseController

  def index
    all_settings = Setting.all.group_by { |s| s.type }
    @settings = []
    @feature_flags = []
    @banner_styles = []
    @banner_imgs = []
    unless all_settings.nil?
      unless all_settings['common'].nil?
        @settings = all_settings['common']
      end
      unless all_settings['feature'].nil?
        @feature_flags = all_settings['feature']
      end
      unless all_settings['banner-style'].nil?
        @banner_styles = all_settings['banner-style']
      end
      unless all_settings['banner-img'].nil?
        @banner_imgs = all_settings['banner-img']
      end
    end
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

end
