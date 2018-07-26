class Admin::SystemEmailsController < Admin::BaseController

  before_action :load_system_email, only: [:view, :preview_pending, :moderate_pending]

  def index
    @system_emails = {
      proposal_notification_digest: %w(view preview_pending)
    }
  end

  def view
    case @system_email
    when "proposal_notification_digest"
      @notifications = Notification.where(notifiable_type: "ProposalNotification").limit(2)
      @subject = t('mailers.proposal_notification_digest.title', org_name: Setting['org_name'])
    end
  end

  def preview_pending
    case @system_email
    when "proposal_notification_digest"
      @previews = ProposalNotification.where(id: unsent_proposal_notifications_ids)
                                      .page(params[:page])
    end
  end

  def moderate_pending
    ProposalNotification.find(params[:id]).moderate_system_email(current_user)

    redirect_to admin_system_email_preview_pending_path("proposal_notification_digest")
  end

  def send_pending
    Notification.delay.send_pending

    flash[:notice] = t("admin.system_emails.preview_pending.send_pending_notification")
    redirect_to admin_system_emails_path
  end

  private

  def load_system_email
    @system_email = params[:system_email_id]
  end

  def unsent_proposal_notifications_ids
    Notification.where(notifiable_type: "ProposalNotification", emailed_at: nil)
                .group(:notifiable_id).count.keys
  end
end
