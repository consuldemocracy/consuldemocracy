if SiteCustomization::Page.find_by(slug: "participacion_ciudadana_en_el_mundo").nil?
  page = SiteCustomization::Page.new(slug: "participacion_ciudadana_en_el_mundo", status: "published")
  page.title = I18n.t("pages.citizen_participation_in_the_world.title")
  page.content = I18n.t("pages.citizen_participation_in_the_world.description")
  page.more_info_flag = true
  page.save!
end
