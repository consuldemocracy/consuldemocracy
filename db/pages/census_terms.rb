def generate_content(page)
  page.title = I18n.t("pages.census_terms.title")
  page.content = "<p>#{I18n.t("pages.census_terms.description")}</p>"
  page.save!
end

if SiteCustomization::Page.find_by(slug: "census_terms").nil?
  page = SiteCustomization::Page.new(slug: "census_terms", status: "published")
  page.print_content_flag = true
  I18n.available_locales.each do |locale|
    I18n.with_locale(locale) { generate_content(page) }
  end
end
