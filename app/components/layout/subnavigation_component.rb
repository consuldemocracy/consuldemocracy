class Layout::SubnavigationComponent < ApplicationComponent
  delegate :content_block, :layout_menu_link_to, to: :helpers

  def render?
    !Rails.application.multitenancy_management_mode?
  end
end
