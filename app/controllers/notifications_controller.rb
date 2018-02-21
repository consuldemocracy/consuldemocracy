class NotificationsController < ApplicationController
  include CustomUrlsHelper

  before_action :authenticate_user!
  after_action :mark_as_read, only: :show
  skip_authorization_check

  def index
    @notifications = current_user.notifications.unread.recent.for_render
  end

  def show
    @notification = current_user.notifications.find(params[:id])
    redirect_to linkable_resource_path
  end

  def mark_all_as_read
    current_user.notifications.each { |notification| notification.mark_as_read }
    redirect_to notifications_path
  end

  private

    def mark_as_read
      @notification.mark_as_read
    end

    def linkable_resource_path
      if @notification.linkable_resource.respond_to?(:path)
        @notification.linkable_resource.path
      else
        path_for @notification.linkable_resource
      end
    end

end
