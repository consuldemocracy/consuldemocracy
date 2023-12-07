class Admin::Settings::TableComponent < ApplicationComponent
  attr_reader :setting_name, :table_class

  def initialize(setting_name:, table_class: "mixed-settings-table")
    @setting_name = setting_name
    @table_class = table_class
  end

  def key_header
    if setting_name == "feature"
      t("admin.settings.setting")
    elsif setting_name == "setting"
      t("admin.settings.setting_name")
    else
      t("admin.settings.#{setting_name}")
    end
  end

  def value_header
    if setting_name == "feature"
      t("admin.settings.index.features.enabled")
    else
      t("admin.settings.setting_value")
    end
  end
end
