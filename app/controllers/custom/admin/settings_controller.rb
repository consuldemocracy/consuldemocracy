require_dependency Rails.root.join("app", "controllers", "admin", "settings_controller").to_s

class Admin::SettingsController
  # alias :old_index :index
  #
  # def index
  #   old_index
  #
  #   all_settings = Setting.all.group_by(&:type)
  #   @show_navbar_settings = all_settings["show_navbar"]
  # end
end
