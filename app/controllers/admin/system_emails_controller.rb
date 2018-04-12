class Admin::SystemEmailsController < Admin::BaseController

  before_action :load_system_email, only: [:view]

  def index
    @system_emails = %w(proposal_notification_digest)
  end

  def view
    case @system_email
    when "proposal_notification_digest"
      @notifications = Notification.where(notifiable_type: "ProposalNotification").limit(2)
      @subject = t('mailers.proposal_notification_digest.title', org_name: Setting['org_name'])
    end
  end

  private

  def load_system_email
    @system_email = params[:system_email_id]
  end
end
