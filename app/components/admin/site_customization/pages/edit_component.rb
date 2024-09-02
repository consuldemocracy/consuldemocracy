class Admin::SiteCustomization::Pages::EditComponent < ApplicationComponent
  include Header
  attr_reader :page

  def initialize(page)
    @page = page
  end

  def title
    t("admin.site_customization.pages.edit.title", page_title: page.title)
  end
end
