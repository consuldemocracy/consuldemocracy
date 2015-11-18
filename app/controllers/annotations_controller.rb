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

  private

  def annotation_params
    params
      .require(:annotation)
      .permit(:quote, :text, ranges: [:start, :startOffset, :end, :endOffset])
      .merge(proposal_id: params[:proposal_id])
  end
end