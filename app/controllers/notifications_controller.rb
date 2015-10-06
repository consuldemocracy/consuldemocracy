class NotificationsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource class: "User"

  def index
    @notifications = current_user.notifications.unread.recent.for_render
  end

end
