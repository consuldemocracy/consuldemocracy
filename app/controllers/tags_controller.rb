class TagsController < ApplicationController
  load_and_authorize_resource
  respond_to :json

  def suggest
    term = params[:term].presence || params[:search]
    tags = term.present? ? Tag.search(term).map(&:name) : []

    render json: { suggestions: tags }
  end
end
