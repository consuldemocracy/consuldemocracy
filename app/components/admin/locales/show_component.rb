class Admin::Locales::ShowComponent < ApplicationComponent
  include Header
  attr_reader :locales, :default

  def initialize(locales, default:)
    @locales = locales
    @default = default
  end

  def title
    t("admin.menu.locales")
  end
end
