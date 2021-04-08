def generate_content(page)
  page.title = I18n.t("pages.accessibility.title")

  content = ""
  I18n.t("pages.accessibility.description").each_line do |line|
    content << "<p>#{line}</p>"
  end
  content << "<ul>"
  I18n.t("pages.accessibility.examples").each do |example|
    content << "<li>#{example}</li>"
  end
  content << "</ul>
              <h2>#{I18n.t("pages.accessibility.keyboard_shortcuts.title")}</h2>
              <p>#{I18n.t("pages.accessibility.keyboard_shortcuts.navigation_table.description")}</p>
              <table>
                <caption class='show-for-sr'>
                  #{I18n.t("pages.accessibility.keyboard_shortcuts.navigation_table.caption")}
                </caption>
                <thead>
                  <tr>
                    <th scope='col' class='text-center'>
                      #{I18n.t("pages.accessibility.keyboard_shortcuts.navigation_table.key_header")}
                    </th>
                    <th scope='col'>
                      #{I18n.t("pages.accessibility.keyboard_shortcuts.navigation_table.page_header")}
                    </th>
                  </tr>
                </thead>
                <tbody>"
  I18n.t("pages.accessibility.keyboard_shortcuts.navigation_table.rows").each do |row|
    if row.present?
      content << "  <tr>
                    <td class='text-center'>#{row[:key_column]}</td>
                    <td>#{row[:page_column]}</td>
                  </tr>"
    end
  end
  content << "  </tbody>
              </table>
              <p>#{I18n.t("pages.accessibility.keyboard_shortcuts.browser_table.description")}</p>
              <table>
                <caption class='show-for-sr'>
                  #{I18n.t("pages.accessibility.keyboard_shortcuts.browser_table.caption")}
                </caption>
                <thead>
                  <tr>
                    <th scope='col'>
                      #{I18n.t("pages.accessibility.keyboard_shortcuts.browser_table.browser_header")}
                    </th>
                    <th scope='col'>
                      #{I18n.t("pages.accessibility.keyboard_shortcuts.browser_table.key_header")}
                    </th>
                  </tr>
                </thead>
                <tbody>"
  I18n.t("pages.accessibility.keyboard_shortcuts.browser_table.rows").each do |row|
    if row.present?
      content << "  <tr>
                    <td>#{row[:browser_column]}</td>
                    <td>#{row[:key_column]}</td>
                  </tr>"
    end
  end
  content << "  </tbody>
              </table>
              <h2>#{I18n.t("pages.accessibility.textsize.title")}</h2>
              <p>#{I18n.t("pages.accessibility.textsize.browser_settings_table.description")}</p>
              <table>
                <thead>
                  <tr>
                    <th scope='col'>
                      #{I18n.t("pages.accessibility.textsize.browser_settings_table.browser_header")}
                    </th>
                    <th scope='col'>
                      #{I18n.t("pages.accessibility.textsize.browser_settings_table.action_header")}
                    </th>
                  </tr>
                </thead>
                <tbody>"
  I18n.t("pages.accessibility.textsize.browser_settings_table.rows").each do |row|
    if row.present?
      content << "  <tr>
                    <td>#{row[:browser_column]}</td>
                    <td>#{row[:action_column]}</td>
                  </tr>"
    end
  end
  content << "  </tbody>
              </table>"
  content << "<p>#{I18n.t("pages.accessibility.textsize.browser_shortcuts_table.description")}</p>
              <ul>"
  I18n.t("pages.accessibility.textsize.browser_shortcuts_table.rows").each do |row|
    if row.present?
      content << "<li><strong>#{row[:shortcut_column]}</strong> #{row[:description_column]}</li>"
    end
  end
  content << "</ul>
              <h2>#{I18n.t("pages.accessibility.compatibility.title")}</h2>
              <p>#{I18n.t("pages.accessibility.compatibility.description")}</p>"

  page.content = content
  page.save!
end

if SiteCustomization::Page.find_by(slug: "accessibility").nil?
  page = SiteCustomization::Page.new(slug: "accessibility", status: "published")
  I18n.available_locales.each do |locale|
    I18n.with_locale(locale) { generate_content(page) }
  end
end
