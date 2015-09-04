class Moderation::CommentsController < Moderation::BaseController
  has_filters %w{pending_flag_review all with_ignored_flag}, only: :index

  before_action :load_comments, only: :index

  load_and_authorize_resource

  def index
    @comments = @comments.send(@current_filter)
    @comments = @comments.page(params[:page])
  end

  def hide
    @comment.hide
  end

  def hide_in_moderation_screen
    @comment.hide
    redirect_to request.query_parameters.merge(action: :index)
  end

  def ignore_flag
    @comment.ignore_flag
    redirect_to request.query_parameters.merge(action: :index)
  end

  private

    def load_comments
      @comments = Comment.accessible_by(current_ability, :hide).flagged.sort_for_moderation.includes(:commentable)
    end

end
