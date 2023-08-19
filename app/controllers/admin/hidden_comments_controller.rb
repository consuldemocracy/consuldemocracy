class Admin::HiddenCommentsController < Admin::BaseController
  include Admin::HiddenContent

  before_action :load_comment, only: [:confirm_hide, :restore]

  def index
    @comments = hidden_content(Comment.not_valuations).with_visible_author
  end

  def confirm_hide
    @comment.confirm_hide
    redirect_with_query_params_to(action: :index)
  end

  def restore
    @comment.restore(recursive: true)
    @comment.ignore_flag
    Activity.log(current_user, :restore, @comment)
    redirect_with_query_params_to(action: :index)
  end

  private

    def load_comment
      @comment = Comment.not_valuations.with_hidden.find(params[:id])
    end
end
