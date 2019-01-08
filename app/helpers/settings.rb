module SettingsHelper

  def setting_for_widget(widget)
    Setting.where(key: 'feature.user.recommendations').first
  end

end