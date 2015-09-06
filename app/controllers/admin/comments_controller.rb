class Admin::CommentsController < Admin::BaseController
  has_filters %w{without_confirmed_hide all with_confirmed_hide}

  before_action :load_comment, only: [:confirm_hide, :restore]

  def index
    @comments = Comment.only_hidden.send(@current_filter).order(hidden_at: :desc).page(params[:page])
  end

  def confirm_hide
    @comment.confirm_hide
    redirect_to request.query_parameters.merge(action: :index)
  end

  def restore
    @comment.restore
    redirect_to request.query_parameters.merge(action: :index)
  end

  private
    def load_comment
      @comment = Comment.with_hidden.find(params[:id])
    end

end
