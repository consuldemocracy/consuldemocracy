if SiteCustomization::Page.find_by_slug("faq").nil?
  page = SiteCustomization::Page.new(slug: "faq", status: "published")
  page.title = I18n.t("pages.help.faq.page.title")
  page.content = "<p>#{I18n.t("pages.help.faq.page.description")}</p>"
  page.save!
end
