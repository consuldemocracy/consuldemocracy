def generate_content(page)
  page.title = I18n.t("pages.help.faq.page.title")
  page.content = "<p>#{I18n.t("pages.help.faq.page.description")}</p>"
  page.save!
end
if SiteCustomization::Page.find_by(slug: "faq").nil?
  page = SiteCustomization::Page.new(slug: "faq", status: "published")
  I18n.available_locales.each do |locale|
    I18n.with_locale(locale) { generate_content(page) }
  end
end
