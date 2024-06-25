class Layout::LoginItemsComponent < ApplicationComponent
  attr_reader :user
  use_helpers :layout_menu_link_to

  def initialize(user)
    @user = user
  end

  private

    def show_my_activity_link?
      !Rails.application.multitenancy_management_mode?
    end
end
