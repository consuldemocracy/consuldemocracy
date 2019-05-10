class TagsController < ApplicationController

  load_and_authorize_resource class: ActsAsTaggableOn::Tag
  respond_to :json

  def suggest
    @tags = ActsAsTaggableOn::Tag.search(params[:search]).map(&:name)
    respond_with @tags
  end

end
