def generate_content(page)
  page.title = I18n.t("pages.privacy.title")
  page.content = I18n.t("pages.privacy.subtitle")
  page.save!
end

if SiteCustomization::Page.find_by(slug: "privacy").nil?
  page = SiteCustomization::Page.new(slug: "privacy", status: "published")
  page.print_content_flag = true
  I18n.available_locales.each do |locale|
    I18n.with_locale(locale) { generate_content(page) }
  end
end
