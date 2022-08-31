class PollsController < ApplicationController
  include FeatureFlags

  feature_flag :polls

  before_action :load_poll, except: [:index]
  before_action :load_active_poll, only: :index

  load_and_authorize_resource

  has_filters %w[current expired]
  has_orders %w[most_voted newest oldest], only: :show

  def index
    @polls = Kaminari.paginate_array(
      @polls.created_by_admin.not_budget.send(@current_filter).includes(:geozones).sort_for_list(current_user)
    ).page(params[:page])
  end

  def show
    @questions = @poll.questions.for_render.sort_for_list
    @poll_questions_answers = Poll::Question::Answer.where(question: @poll.questions)
                                                    .with_content.order(:given_order)
    @commentable = @poll
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
  end

  def stats
    @stats = Poll::Stats.new(@poll)
  end

  def results
  end

  private

    def load_poll
      @poll = Poll.find_by_slug_or_id!(params[:id])
    end

    def load_active_poll
      @active_poll = ActivePoll.first
    end
end
