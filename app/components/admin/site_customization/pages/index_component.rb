class Admin::SiteCustomization::Pages::IndexComponent < ApplicationComponent
  include Header

  attr_reader :pages
  delegate :page_entries_info, :paginate, to: :helpers

  def initialize(pages)
    @pages = pages
  end

  private

    def title
      t("admin.site_customization.pages.index.title")
    end
end
