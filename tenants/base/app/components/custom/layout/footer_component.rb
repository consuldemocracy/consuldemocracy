require_dependency Rails.root.join("app", "components", "layout", "footer_component").to_s

class Layout::FooterComponent
  delegate :image_path_for, to: :helpers
end
