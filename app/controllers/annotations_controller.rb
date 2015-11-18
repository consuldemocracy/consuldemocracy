class AnnotationsController < ApplicationController
  skip_before_action :verify_authenticity_token
  load_and_authorize_resource

  def create
    @annotation = Annotation.new(annotation_params)
    if @annotation.save
      render json: @annotation.to_json
    end
  end

  def update
    @annotation = Annotation.find(params[:id])
    if @annotation.update_attributes(annotation_params)
      render json: @annotation.to_json
    end
  end

  def destroy
    @annotation = Annotation.find(params[:id])
    @annotation.destroy
    render json: { status: :ok }
  end

  def search
    @annotations = Annotation.where(proposal_id: params[:proposal_id])
    annotations_hash = { total: @annotations.size, rows: @annotations }
    render json: annotations_hash.to_json
  end

  private

  def annotation_params
    params
      .require(:annotation)
      .permit(:quote, :text, ranges: [:start, :startOffset, :end, :endOffset])
      .merge(proposal_id: params[:proposal_id], user_id: params[:user_id])
  end
end