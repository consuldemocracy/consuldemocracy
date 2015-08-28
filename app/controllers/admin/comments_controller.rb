class Admin::CommentsController < Admin::BaseController
  before_filter :set_valid_filters, only: :index
  before_filter :parse_filter, only: :index

  before_filter :load_comment, only: [:confirm_hide, :restore]

  def index
    @comments = Comment.only_hidden.send(@filter).page(params[:page])
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

    def set_valid_filters
      @valid_filters = %w{all with_confirmed_hide}
    end

    def parse_filter
      @filter = params[:filter]
      @filter = 'all' unless @valid_filters.include?(@filter)
    end

end
