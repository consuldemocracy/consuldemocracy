class Admin::HiddenProposalNotificationsController < Admin::BaseController
  include Admin::HiddenContent

  before_action :load_proposal, only: [:confirm_hide, :restore]

  def index
    @proposal_notifications = hidden_content(ProposalNotification.all)
  end

  def confirm_hide
    @proposal_notification.confirm_hide
    redirect_with_query_params_to(action: :index)
  end

  def restore
    @proposal_notification.restore
    @proposal_notification.ignore_flag
    Activity.log(current_user, :restore, @proposal_notification)
    redirect_with_query_params_to(action: :index)
  end

  private

    def load_proposal
      @proposal_notification = ProposalNotification.with_hidden.find(params[:id])
    end
end
