class TagsController < ApplicationController
  load_and_authorize_resource
  respond_to :json

  def suggest
    tags = params[:term].present? ? Tag.search(params[:term]).map(&:name) : []

    render json: { suggestions: tags }
  end
end
