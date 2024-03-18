class Layout::LoginItemsComponent < ApplicationComponent
  attr_reader :user
  use_helpers :layout_menu_link_to

  def initialize(user)
    @user = user
  end
end
