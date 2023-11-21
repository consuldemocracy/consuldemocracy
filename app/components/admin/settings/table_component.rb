class Admin::Settings::TableComponent < ApplicationComponent
  attr_reader :settings, :setting_name, :tab
  delegate :dom_id, to: :helpers

  def initialize(settings:, setting_name:, tab: nil)
    @settings = settings
    @setting_name = setting_name
    @tab = tab
  end

  def display_setting_name(setting_name)
    if setting_name == "setting"
      t("admin.settings.setting_name")
    else
      t("admin.settings.#{setting_name}")
    end
  end
end
