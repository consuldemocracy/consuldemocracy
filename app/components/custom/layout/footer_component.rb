class Layout::FooterComponent < ApplicationComponent
    require_dependency Rails.root.join("app", "components", "admin", "table_actions_component").to_s  
end
