class PollsController < ApplicationController
  include FeatureFlags

  feature_flag :polls

  before_action :load_poll, except: [:index]
  before_action :load_active_poll, only: :index

  load_and_authorize_resource

  has_filters %w[current expired]
  has_orders %w[most_voted newest oldest], only: [:show, :answer]

  def index
    @polls = Kaminari.paginate_array(
      @polls.created_by_admin.not_budget.send(@current_filter).includes(:geozones).sort_for_list(current_user)
    ).page(params[:page])
  end

  def show
    @web_vote = Poll::WebVote.new(@poll, current_user)
    @comment_tree = CommentTree.new(@poll, params[:page], @current_order)
  end

  def answer
    raise CanCan::AccessDenied if @poll.voted_in_booth?(current_user)

    @web_vote = Poll::WebVote.new(@poll, current_user)

    if @web_vote.update(answer_params)
      if answer_params.blank?
        redirect_to @poll, notice: t("flash.actions.create.poll_voter_blank")
      else
        redirect_to @poll, notice: t("flash.actions.create.poll_voter")
      end
    else
      @comment_tree = CommentTree.new(@poll, params[:page], @current_order)
      render :show
    end
  end

  def stats
    @stats = Poll::Stats.new(@poll).tap(&:generate)
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

    def answer_params
      params[:web_vote] || {}
    end
end
