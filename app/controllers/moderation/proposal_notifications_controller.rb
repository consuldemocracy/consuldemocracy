class Moderation::ProposalNotificationsController < Moderation::BaseController
  include ModerateActions

  has_filters %w[pending_review all ignored], only: :index
  has_orders %w[created_at moderated], only: :index

  before_action :load_resources, only: [:index, :moderate]

  load_and_authorize_resource

  def hide
    resource.update(moderated: true)
    respond_to do |format|
      format.js do
        render "moderation/shared/hide", locals: { resource: resource }
      end
    end
  end

  private

    def resource_name
      "proposal_notification"
    end

    def resource_model
      ProposalNotification
    end
end
