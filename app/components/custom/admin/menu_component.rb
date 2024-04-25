require_dependency Rails.root.join("app", "components", "admin", "menu_component").to_s

class Admin::MenuComponent
  def maps?
    controller_name == "maps"
  end

  def maps_link
    [
      t("admin.menu.maps"),
      admin_maps_path,
      maps?
    ]
  end

  def settings_links
    link_to(t("admin.menu.title_settings"), "#", class: "settings-link") +
      link_list(
        settings_link,
        tenants_link,
        tags_link,
        geozones_link,
        images_link,
        content_blocks_link,
        local_census_records_link,
        maps_link,
        class: ("is-active" if settings?)
      )
  end
end
