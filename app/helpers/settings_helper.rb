module SettingsHelper

  def feature?(name)
    setting["feature.#{name}"].presence
  end

  def setting
    @all_settings ||= Hash[ Setting.all.map{|s| [s.key, s.value.presence]} ]
  end

end