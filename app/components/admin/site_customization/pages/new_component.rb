class Admin::SiteCustomization::Pages::NewComponent < ApplicationComponent
  include Header
  attr_reader :page

  def initialize(page)
    @page = page
  end

  def title
    t("admin.site_customization.pages.new.title")
  end
end
