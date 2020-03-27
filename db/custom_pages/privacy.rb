if SiteCustomization::Page.find_by(slug: "privacy").nil?
  page = SiteCustomization::Page.new(slug: "privacy", status: "published")
  page.print_content_flag = true
  page.title = I18n.t("pages.privacy.title")
  page.subtitle = I18n.t("pages.privacy.subtitle")
  page.content = I18n.t("pages.privacy.description")
  page.save!
end
