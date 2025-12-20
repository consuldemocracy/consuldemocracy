class Admin::Poll::NotificationController < Admin::Poll::BaseController
  before_action :load_poll

  def show; end

  def deliver
    if @poll.notifications_sent_at.blank?
      @poll.update!(notifications_sent_at: Time.zone.now)
      User.receive_poll_notifications.find_each do |user|
        Mailer.poll_notification(@poll, user).deliver_now
      end
    end

    redirect_to admin_poll_notification_show_path(@poll)
  end

  private

    def load_poll
      @poll = ::Poll.find(params[:poll_id])
    end
end
