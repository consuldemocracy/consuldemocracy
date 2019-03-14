if SiteCustomization::Page.find_by_slug("conditions").nil?
  page = SiteCustomization::Page.new(slug: "conditions", status: "published")
  page.print_content_flag = true
  page.title = I18n.t("pages.conditions.title")
  page.subtitle = I18n.t("pages.conditions.subtitle")
  page.content = "<p>#{I18n.t("pages.conditions.description")}</p>"
  page.save!
end
