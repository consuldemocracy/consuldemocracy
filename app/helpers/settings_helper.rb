module SettingsHelper
  def feature?(name)
    setting["feature.#{name}"].presence || setting["process.#{name}"].presence || setting[name].presence
  end

  def setting
    @all_settings ||= Setting.all.to_h { |s| [s.key, s.value.presence] }
  end
end
