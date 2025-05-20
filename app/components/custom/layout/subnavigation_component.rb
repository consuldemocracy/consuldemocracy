class Layout::SubnavigationComponent < ApplicationComponent; end

load Rails.root.join("app", "components", "layout", "subnavigation_component.rb")

class Layout::SubnavigationComponent < ApplicationComponent
  use_helpers :content_block, :layout_menu_link_to

  def render?
    !Rails.application.multitenancy_management_mode?
  end
end
