if SiteCustomization::Page.find_by(slug: "faq").nil?
  page = SiteCustomization::Page.new(slug: "faq", status: "published")
  page.title = I18n.t("pages.help.faq.page.title")
  page.content = I18n.t("pages.help.faq.page.description")
  page.print_content_flag = true
  page.save!
end
