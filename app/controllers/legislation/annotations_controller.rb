class Legislation::AnnotationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :authenticate_user!, only: [:create]

  load_and_authorize_resource :process
  load_and_authorize_resource :draft_version, through: :process
  load_and_authorize_resource

  def create
    @annotation = Legislation::Annotation.new(annotation_params)
    @annotation.user = current_user
    if @annotation.save
      render json: @annotation.to_json
    end
  end

  def search
    @annotations = Legislation::Annotation.where(legislation_draft_version_id: params[:legislation_draft_version_id])
    annotations_hash = { total: @annotations.size, rows: @annotations }
    render json: annotations_hash.to_json
  end

  private

  def annotation_params
    params
      .require(:annotation)
      .permit(:quote, :text, ranges: [:start, :startOffset, :end, :endOffset])
      .merge(legislation_draft_version_id: params[:legislation_draft_version_id])
  end
end
