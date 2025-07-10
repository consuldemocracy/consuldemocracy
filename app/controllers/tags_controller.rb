class TagsController < ApplicationController
  load_and_authorize_resource
  respond_to :json

  def suggest
    @tags = Tag.search(params[:search]).map(&:name)
    respond_with @tags
  end
end
