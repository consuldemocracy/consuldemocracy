class Moderation::CommentsController < Moderation::BaseController
  before_filter :set_valid_filters, only: :index
  before_filter :parse_filter, only: :index
  before_filter :load_comments, only: :index

  load_and_authorize_resource

  def index
    @comments = @comments.send(@filter)
    @comments = @comments.page(params[:page])
  end

  def hide
    @comment.hide
  end

  def hide_in_moderation_screen
    @comment.hide
    redirect_to request.query_parameters.merge(action: :index)
  end

  def mark_as_reviewed
    @comment.mark_as_reviewed
    redirect_to request.query_parameters.merge(action: :index)
  end

  private

    def load_comments
      @comments = Comment.accessible_by(current_ability, :hide).flagged_as_inappropiate.sorted_for_moderation.includes(:commentable)
    end

    def set_valid_filters
      @valid_filters = %w{all pending_review archived}
    end

    def parse_filter
      @filter = params[:filter]
      @filter = 'all' unless @valid_filters.include?(@filter)
    end

end
