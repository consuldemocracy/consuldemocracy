class Api::V1::ProposalsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  authorize_resource

  def index
    begin
      proposals = Proposal.all.page(params[:page])
      render json: proposals, each_serializer: Api::V1::Proposals::IndexSerializer
    rescue
      render json: {errors: [{status: 404, title: "not-found"}]}.to_json, status: 404
    end
  end

  def show
    begin
      # https://github.com/rails-api/active_model_serializers/pull/1156#issuecomment-142320010
      proposal = Proposal.find(params[:id])
      render json: proposal, serializer: Api::V1::Proposals::ShowSerializer
    rescue
      render json: {errors: [{status: 404, title: "not-found"}]}.to_json, status: 404
    end
  end
end
