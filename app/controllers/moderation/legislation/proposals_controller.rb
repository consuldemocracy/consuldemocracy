class Moderation::Legislation::ProposalsController < Moderation::BaseController
  include ModerateActions
  include FeatureFlags

  has_filters %w[pending_flag_review all with_ignored_flag], only: :index
  has_orders %w[flags created_at], only: :index

  feature_flag :legislation

  before_action :load_resources, only: [:index, :moderate]

  load_and_authorize_resource class: "Legislation::Proposal"

  private

    def resource_model
      Legislation::Proposal
    end
end
