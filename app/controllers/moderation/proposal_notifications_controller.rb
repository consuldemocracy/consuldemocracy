class Moderation::ProposalNotificationsController < Moderation::BaseController
  include ModerateActions

  has_filters %w{pending_review all ignored}, only: :index
  has_orders %w{created_at moderated}, only: :index

  before_action :load_resources, only: [:index, :moderate]

  load_and_authorize_resource

  def hide
    ProposalNotification.find(params[:id]).update(moderated: true)
  end

  private

    def resource_name
      'proposal_notification'
    end

    def resource_model
      ProposalNotification
    end
end
