class Moderation::CommentsController < Moderation::BaseController
  has_filters %w{pending_flag_review all with_ignored_flag}, only: :index
  has_orders %w{flags created_at}, only: :index

  before_action :load_comments, only: [:index, :moderate]

  load_and_authorize_resource

  def index
    @comments = @comments.send(@current_filter)
                       .send("sort_by_#{@current_order}")
                       .page(params[:page])
                       .per(50)
  end

  def hide
    hide_comment @comment
  end

  def moderate
    @comments = @comments.where(id: params[:comment_ids])

    if params[:hide_comments].present?
      @comments.accessible_by(current_ability, :hide).each {|comment| hide_comment comment}

    elsif params[:ignore_flags].present?
      @comments.accessible_by(current_ability, :ignore_flag).each(&:ignore_flag)

    elsif params[:block_authors].present?
      author_ids = @comments.pluck(:user_id).uniq
      User.where(id: author_ids).accessible_by(current_ability, :block).each(&:block)
    end

    redirect_to request.query_parameters.merge(action: :index)
  end

  private

    def load_comments
      @comments = Comment.accessible_by(current_ability, :moderate)
    end

    def hide_comment(comment)
      comment.hide
      Activity.log(current_user, :hide, comment)
    end

end
