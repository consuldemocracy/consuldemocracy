class NotificationsController < ApplicationController
  include CustomUrlsHelper

  before_action :authenticate_user!
  skip_authorization_check

  respond_to :html, :js

  def index
    @notifications = current_user.notifications.unread
  end

  def show
    @notification = current_user.notifications.find(params[:id])
    @notification.mark_as_read
    redirect_to linkable_resource_path(@notification)
  end

  def read
    @notifications = current_user.notifications.read
  end

  def mark_all_as_read
    current_user.notifications.unread.each { |notification| notification.mark_as_read }
    redirect_to notifications_path
  end

  def mark_as_read
    @notification = current_user.notifications.find(params[:id])
    @notification.mark_as_read
  end

  def mark_as_unread
    @notification = current_user.notifications.find(params[:id])
    @notification.mark_as_unread
  end

  private

    def linkable_resource_path(notification)
      case notification.linkable_resource.class.name
      when "Budget::Investment"
        budget_investment_path @notification.linkable_resource.budget, @notification.linkable_resource
      when "Topic"
        community_topic_path @notification.linkable_resource.community, @notification.linkable_resource
      else
        url_for @notification.linkable_resource
      end
    end

end
