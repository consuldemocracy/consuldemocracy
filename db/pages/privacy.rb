if SiteCustomization::Page.find_by(slug: "privacy")&.translations&.find_by(locale: I18n.locale).nil?
  page = SiteCustomization::Page.find_by(slug: "privacy") || SiteCustomization::Page.new(slug: "privacy", status: "published")
  page.print_content_flag = true
  page.title = I18n.t("pages.privacy.title")
  page.content = I18n.t("pages.privacy.subtitle")
  page.save!
end
