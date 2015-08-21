class Moderation::CommentsController < Moderation::BaseController

  before_filter :load_comments, only: :index

  load_and_authorize_resource

  def index
    @comments = @comments.page(params[:page])
  end

  def hide
    @comment.hide
  end

  def hide_in_moderation_screen
    @comment.hide
    redirect_to action: :index
  end

  def mark_as_reviewed
    @comment.mark_as_reviewed
    redirect_to action: :index
  end

  private

  def load_comments
    @comments = Comment.accessible_by(current_ability, :hide).where('inappropiate_flags_count > 0').includes(:commentable)
  end

end
