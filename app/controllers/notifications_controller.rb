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
    # TODO: Parche, url_for no genera una ruta correcta para Budget::Investment
    if @notification.linkable_resource.class == Budget::Investment
      redirect_to url_for(budget_investment_path(@notification.linkable_resource.budget_id, @notification.linkable_resource.id))
    else
      redirect_to url_for(@notification.linkable_resource)
    end
  end

  def mark_all_as_read
    current_user.notifications.each { |notification| notification.mark_as_read }
    redirect_to notifications_path
  end

  private

    def mark_as_read
      @notification.mark_as_read
    end

end
