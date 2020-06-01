if SiteCustomization::Page.find_by(slug: "faq")&.translations&.find_by(locale: I18n.locale).nil?
  page = SiteCustomization::Page.find_by(slug: "faq") || SiteCustomization::Page.new(slug: "faq", status: "published")
  page.title = I18n.t("pages.help.faq.page.title")
  page.content = "<p>#{I18n.t("pages.help.faq.page.description")}</p>"
  page.save!
end
