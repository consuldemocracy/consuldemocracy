class Admin::AdminNotificationsController < Admin::BaseController
  include Translatable

  def index
    @admin_notifications = AdminNotification.all
  end

  def show
    @admin_notification = AdminNotification.find(params[:id])
  end

  def new
    @admin_notification = AdminNotification.new
  end

  def create
    @admin_notification = AdminNotification.new(admin_notification_params)

    if @admin_notification.save
      notice = t("admin.admin_notifications.create_success")
      redirect_to [:admin, @admin_notification], notice: notice
    else
      render :new
    end
  end

  def edit
    @admin_notification = AdminNotification.find(params[:id])
  end

  def update
    @admin_notification = AdminNotification.find(params[:id])

    if @admin_notification.update(admin_notification_params)
      notice = t("admin.admin_notifications.update_success")
      redirect_to [:admin, @admin_notification], notice: notice
    else
      render :edit
    end
  end

  def destroy
    @admin_notification = AdminNotification.find(params[:id])
    @admin_notification.destroy

    notice = t("admin.admin_notifications.delete_success")
    redirect_to admin_admin_notifications_path, notice: notice
  end

  def deliver
    @admin_notification = AdminNotification.find(params[:id])

    if @admin_notification.valid?
      @admin_notification.deliver
      flash[:notice] = t("admin.admin_notifications.send_success")
    else
      flash[:error] = t("admin.segment_recipient.invalid_recipients_segment")
    end

    redirect_to [:admin, @admin_notification]
  end

  private

    def admin_notification_params
      attributes = [:title, :body, :link, :segment_recipient,
                    *translation_params(AdminNotification)]

      params.require(:admin_notification).permit(attributes)
    end

    def resource
      AdminNotification.find(params[:id])
    end
end
