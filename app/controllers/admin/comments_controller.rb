class Admin::CommentsController < Admin::BaseController
  has_filters %w{without_confirmed_hide all with_confirmed_hide}

  before_action :load_comment, only: [:confirm_hide, :restore]

  def index
    @comments = Comment.not_valuations.only_hidden.with_visible_author
                       .send(@current_filter).order(hidden_at: :desc).page(params[:page])
  end

  def confirm_hide
    @comment.confirm_hide
    redirect_to request.query_parameters.merge(action: :index)
  end

  def restore
    @comment.restore
    @comment.ignore_flag
    Activity.log(current_user, :restore, @comment)
    redirect_to request.query_parameters.merge(action: :index)
  end

  private

    def load_comment
      @comment = Comment.not_valuations.with_hidden.find(params[:id])
    end

end
