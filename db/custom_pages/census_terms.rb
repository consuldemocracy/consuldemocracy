if SiteCustomization::Page.find_by(slug: "census_terms").nil?
  page = SiteCustomization::Page.new(slug: "census_terms", status: "published")
  page.print_content_flag = false
  page.more_info_flag = false
  page.title = I18n.t("pages.census_terms.title")
  page.content = I18n.t("pages.census_terms.description")
  page.save!
end
