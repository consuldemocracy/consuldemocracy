class Admin::SystemEmailsController < Admin::BaseController

  def index
    @system_emails = %w(proposal_notification_digest)
  end

end
