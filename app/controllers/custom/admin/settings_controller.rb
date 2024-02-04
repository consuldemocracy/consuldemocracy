require_dependency Rails.root.join("app", "controllers", "admin", "settings_controller").to_s

class Admin::SettingsController
  alias :old_index :index

  def index
    old_index

    all_settings = Setting.all.group_by(&:type)
    @participation_processes_navbar_settings = all_settings["process_navbar"]
  end
end
