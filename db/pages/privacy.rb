if SiteCustomization::Page.find_by_slug("privacy").nil?
  page = SiteCustomization::Page.new(slug: "privacy", status: "published")
  page.print_content_flag = true
  page.title = I18n.t("pages.privacy.title")
  page.subtitle = I18n.t("pages.privacy.subtitle")

  content = "<ol>"
  I18n.t("pages.privacy.info_items").each do |item|
    if item.key?(:text)
      content << "<li>#{item[:text]}</li>"
    else
      content << "<ul>"
      item[:subitems].each do |subitem|
        content << "<li>
                      <strong> #{subitem[:field]}</strong>
                      #{subitem[:description]}
                    </li>"
      end
      content << "</ul>"
    end
  end
  content << "</ol>"

  page.content = content
  page.save!
end
