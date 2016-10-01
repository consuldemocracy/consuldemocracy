class Api::V1::CommentsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  authorize_resource

  def index
    begin
      # requests coming from links provided by /proposals, /spending_proposals and /debates
      if (params[:commentable_id] && params[:commentable_type])
        comments = Comment.where(commentable_id: params[:commentable_id], commentable_type: params[:commentable_type]).page(params[:page])
      # standard request
      else
        comments = Comment.all.page(params[:page])
      end
      render json: comments, each_serializer: Api::V1::Comments::IndexSerializer
    rescue
      render json: {errors: [{status: 404, title: "not-found"}]}.to_json, status: 404
    end
  end

  def show
    begin
      # https://github.com/rails-api/active_model_serializers/pull/1156#issuecomment-142320010
      comment = Comment.find(params[:id])
      render json: comment, serializer: Api::V1::Comments::ShowSerializer
    rescue
      render json: {errors: [{status: 404, title: "not-found"}]}.to_json, status: 404
    end
  end
end
