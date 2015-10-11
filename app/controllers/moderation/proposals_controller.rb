class Moderation::ProposalsController < Moderation::BaseController
  include ModerateActions

  has_filters %w{pending_flag_review all with_ignored_flag}, only: :index
  has_orders %w{flags created_at}, only: :index

  before_filter :load_resources, only: [:index, :moderate]

  load_and_authorize_resource

  private

    def resource_model
      Proposal
    end
end
