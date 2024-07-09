require_dependency Rails.root.join("app", "components", "admin", "menu_component").to_s

class Admin::MenuComponent
  def maps_link
    [
      t("admin.menu.maps"),
      admin_maps_path,
      maps?
    ]
  end
end
