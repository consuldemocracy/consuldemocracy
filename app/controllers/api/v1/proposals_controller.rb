class Api::V1::ProposalsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  load_and_authorize_resource

  def index
    @proposals = @proposals.page(params[:page])
    render json: @proposals, each_serializer: Api::V1::Proposals::IndexSerializer
  end

  def show
    # https://github.com/rails-api/active_model_serializers/pull/1156#issuecomment-142320010
    render json: @proposal, serializer: Api::V1::Proposals::ShowSerializer
  end
end
