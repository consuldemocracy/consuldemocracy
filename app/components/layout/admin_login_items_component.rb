class Layout::AdminLoginItemsComponent < ApplicationComponent
  attr_reader :user
  delegate :show_admin_menu?, to: :helpers

  def initialize(user)
    @user = user
  end

  def render?
    show_admin_menu?(user)
  end
end
