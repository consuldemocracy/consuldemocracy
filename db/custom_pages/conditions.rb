if SiteCustomization::Page.find_by(slug: "conditions").nil?
  page = SiteCustomization::Page.new(slug: "conditions", status: "published")
  page.print_content_flag = true
  page.title = I18n.t("pages.conditions.title")
  page.subtitle = I18n.t("pages.conditions.subtitle")
  page.content = I18n.t("pages.conditions.description")
  page.save!
end
