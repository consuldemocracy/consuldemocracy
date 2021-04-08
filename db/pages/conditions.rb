def generate_content(page)
  page.title = I18n.t("pages.conditions.title")
  page.subtitle = I18n.t("pages.conditions.subtitle")
  page.content = "<p>#{I18n.t("pages.conditions.description")}</p>"
  page.save!
end

if SiteCustomization::Page.find_by(slug: "conditions").nil?
  page = SiteCustomization::Page.new(slug: "conditions", status: "published")
  page.print_content_flag = true
  I18n.available_locales.each do |locale|
    I18n.with_locale(locale) { generate_content(page) }
  end
end
