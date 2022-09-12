if SiteCustomization::Page.find_by(slug: "hechos_sobre_participacion_ciudadana").nil?
  page = SiteCustomization::Page.new(slug: "hechos_sobre_participacion_ciudadana", status: "published")
  page.title = I18n.t("pages.facts_about_citizen_participation.title")
  page.content = I18n.t("pages.facts_about_citizen_participation.description")
  page.more_info_flag = true
  page.save!
end
