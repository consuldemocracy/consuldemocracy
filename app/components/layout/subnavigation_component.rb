class Layout::SubnavigationComponent < ApplicationComponent
  delegate :content_block, :layout_menu_link_to, to: :helpers
end
