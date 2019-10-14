class Moderation::DebatesController < Moderation::BaseController
  include ModerateActions
  include FeatureFlags

  has_filters %w{pending_flag_review all with_ignored_flag}, only: :index
  has_orders %w{flags created_at}, only: :index

  feature_flag :debates

  before_action :load_resources, only: [:index, :moderate]

  load_and_authorize_resource

  private

    def resource_model
      Debate
    end

end
