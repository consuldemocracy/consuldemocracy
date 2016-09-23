class Api::V1::CommentsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  authorize_resource

  def index
    begin
      comments = Comment.all.page(params[:page])
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
