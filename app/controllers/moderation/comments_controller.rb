class Moderation::CommentsController < Moderation::BaseController
  include ModerateActions

  has_filters %w{pending_flag_review all with_ignored_flag}, only: :index
  has_orders %w{flags newest}, only: :index

  before_action :load_resources, only: [:index, :moderate]

  load_and_authorize_resource

  private

    def resource_model
      Comment
    end

    def author_id
      :user_id
    end
end
