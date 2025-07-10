if SiteCustomization::Page.find_by(slug: "informacion_presupuestos_participativos").nil?
  page = SiteCustomization::Page.new(slug: "informacion_presupuestos_participativos", status: "published")
  page.print_content_flag = false
  page.more_info_flag = true
  page.title = I18n.t("pages.budgets_info.title")
  page.content = I18n.t("pages.budgets_info.description")
  page.save!
end
