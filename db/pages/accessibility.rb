module DefaultAccessibilityPage
  class << self
    def descriptions
      I18n.t("pages.accessibility.description").lines.map do |line|
        "<p>#{line}</p>"
      end.join
    end

    def examples_list
      "<ul>#{examples_items}</ul>"
    end

    def examples_items
      examples_items_texts.map do |example|
        "<li>#{example}</li>"
      end.join
    end

    def examples_items_texts
      I18n.t("pages.accessibility.examples")
    end

    def shortcuts_table
      "<h2>#{I18n.t("pages.accessibility.keyboard_shortcuts.title")}</h2>
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
         <tbody>
           #{shortcuts_rows}
         </tbody>
       </table>"
    end

    def shortcuts_rows
      shortcuts_rows_texts.map do |row|
        "<tr>
           <td class='text-center'>#{row[:key_column]}</td>
           <td>#{row[:page_column]}</td>
         </tr>"
      end.join
    end

    def shortcuts_rows_texts
      I18n.t("pages.accessibility.keyboard_shortcuts.navigation_table.rows").compact_blank
    end

    def browsers_table
      "<p>#{I18n.t("pages.accessibility.keyboard_shortcuts.browser_table.description")}</p>
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
         <tbody>
           #{browsers_rows}
         </tbody>
       </table>"
    end

    def browsers_rows
      browsers_rows_texts.map do |row|
        "<tr>
           <td>#{row[:browser_column]}</td>
           <td>#{row[:key_column]}</td>
         </tr>"
      end.join
    end

    def browsers_rows_texts
      I18n.t("pages.accessibility.keyboard_shortcuts.browser_table.rows").compact_blank
    end

    def textsize_table
      "<h2>#{I18n.t("pages.accessibility.textsize.title")}</h2>
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
         <tbody>
           #{textsize_rows}
         </tbody>
       </table>"
    end

    def textsize_rows
      texsize_rows_texts.map do |row|
        "<tr>
           <td>#{row[:browser_column]}</td>
           <td>#{row[:action_column]}</td>
         </tr>"
      end.join
    end

    def texsize_rows_texts
      I18n.t("pages.accessibility.textsize.browser_settings_table.rows").compact_blank
    end

    def browser_shortcuts
      "<p>#{I18n.t("pages.accessibility.textsize.browser_shortcuts_table.description")}</p>
       #{browser_shortcuts_list}"
    end

    def browser_shortcuts_list
      "<ul>#{browser_shortcuts_items}</ul>"
    end

    def browser_shortcuts_items
      browser_shortcuts_items_texts.map do |item|
        "<li><strong>#{item[:shortcut_column]}</strong> #{item[:description_column]}</li>"
      end.join
    end

    def browser_shortcuts_items_texts
      I18n.t("pages.accessibility.textsize.browser_shortcuts_table.rows").compact_blank
    end

    def compatibility
      "<h2>#{I18n.t("pages.accessibility.compatibility.title")}</h2>
       <p>#{I18n.t("pages.accessibility.compatibility.description")}</p>"
    end

    def content
      descriptions + examples_list + shortcuts_table + browsers_table + textsize_table +
        browser_shortcuts + compatibility
    end
  end
end

if SiteCustomization::Page.find_by(slug: "accessibility").nil?
  page = SiteCustomization::Page.new(slug: "accessibility", status: "published")
  Setting.enabled_locales.each do |locale|
    I18n.with_locale(locale) do
      page.title = I18n.t("pages.accessibility.title")
      page.content = DefaultAccessibilityPage.content
      page.save!
    end
  end
end
