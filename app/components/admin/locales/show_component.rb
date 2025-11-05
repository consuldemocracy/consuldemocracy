class Admin::Locales::ShowComponent < ApplicationComponent
  include Header

  attr_reader :locales_settings

  def initialize(locales_settings)
    @locales_settings = locales_settings
  end

  def title
    t("admin.menu.locales")
  end
end
