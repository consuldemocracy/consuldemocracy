class Legislation::AnnotationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :authenticate_user!, only: [:create]

  load_and_authorize_resource :process
  load_and_authorize_resource :draft_version, through: :process
  load_and_authorize_resource

  has_orders %w{most_voted newest oldest}, only: :show

  def index
  end

  def show
    @commentable = @annotation
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
    set_comment_flags(@comment_tree.comments)
  end

  def create
    @annotation = Legislation::Annotation.new(annotation_params)
    @annotation.author = current_user
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
