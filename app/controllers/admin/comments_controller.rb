class Admin::CommentsController < Admin::BaseController

  has_filters %w{all with_confirmed_hide}

  before_filter :load_comment, only: [:confirm_hide, :restore]

  def index
    @comments = Comment.only_hidden.send(@current_filter).page(params[:page])
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
