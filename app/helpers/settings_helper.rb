module SettingsHelper

  def feature?(name)
    setting["feature.#{name}"].presence || setting["process.#{name}"].presence
  end

  def setting
    @all_settings ||= Hash[ Setting.all.map{|s| [s.key, s.value.presence]} ]
  end

  def display_setting_name(setting_name)
    if setting_name == "setting"
      t("admin.settings.setting_name")
    else
      t("admin.settings.#{setting_name}")
    end
  end

end
