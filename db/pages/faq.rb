def generate_content(page)
  page.title = I18n.t("pages.help.faq.page.title")
  page.content = "<p>#{I18n.t("pages.help.faq.page.description")}</p>"
  page.save!
end
if SiteCustomization::Page.find_by(slug: "faq").nil?
  page = SiteCustomization::Page.new(slug: "faq", status: "published")
  generate_content(page)
  I18n.available_locales.each do |locale|
    I18n.locale = locale
    translation = page.translations.build(locale: locale)
    generate_content(translation)
  end
end
