class AnnotationsController < ApplicationController
  skip_before_action :verify_authenticity_token
  load_and_authorize_resource

  def create
    @annotation = Annotation.new(annotation_params)
    @annotation.user = current_user
    if @annotation.save
      render json: @annotation.to_json(methods: :permissions)
    end
  end

  def update
    @annotation = Annotation.find(params[:id])
    if @annotation.update_attributes(annotation_params)
      render json: @annotation.to_json(methods: :permissions)
    end
  end

  def destroy
    @annotation = Annotation.find(params[:id])
    @annotation.destroy
    render json: { status: :ok }
  end

  def search
    @annotations = Annotation.where(legacy_legislation_id: params[:legacy_legislation_id])
    annotations_hash = { total: @annotations.size, rows: @annotations }
    render json: annotations_hash.to_json(methods: :permissions)
  end

  private

  def annotation_params
    params
      .require(:annotation)
      .permit(:quote, :text, ranges: [:start, :startOffset, :end, :endOffset])
      .merge(legacy_legislation_id: params[:legacy_legislation_id])
  end
end
