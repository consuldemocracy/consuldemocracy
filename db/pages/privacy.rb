if SiteCustomization::Page.find_by_slug("privacy").nil?
  page = SiteCustomization::Page.new(slug: "privacy", status: "published")
  page.print_content_flag = true
  page.title = I18n.t("pages.privacy.title")
  page.content = I18n.t("pages.privacy.subtitle")
  page.save!
end
