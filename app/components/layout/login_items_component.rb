class Layout::LoginItemsComponent < ApplicationComponent
  attr_reader :user
  delegate :layout_menu_link_to, to: :helpers

  def initialize(user)
    @user = user
  end
end
