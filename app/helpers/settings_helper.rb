module SettingsHelper
  def setting(key)
    Setting[key]
  end
end
