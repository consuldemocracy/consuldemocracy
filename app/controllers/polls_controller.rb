class PollsController < ApplicationController
  include PollsHelper

  before_action :load_active_poll, only: :index

  load_and_authorize_resource

  has_filters %w[current expired]
  has_orders %w{most_voted newest oldest}, only: :show

  ::Poll::Answer # trigger autoload

  def index
    @polls = @polls.send(@current_filter).includes(:geozones).sort_for_list.page(params[:page])
  end

  def show
    @questions = @poll.questions.for_render.sort_for_list
    @token = poll_voter_token(@poll, current_user)
    @poll_questions_answers = Poll::Question::Answer.where(question: @poll.questions).where.not(description: "").order(:given_order)

    @answers_by_question_id = {}
    poll_answers = ::Poll::Answer.by_question(@poll.question_ids).by_author(current_user.try(:id))
    poll_answers.each do |answer|
      @answers_by_question_id[answer.question_id] = answer.answer
    end

    @commentable = @poll
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
  end

  def stats
    @stats = Poll::Stats.new(@poll).generate
  end

  def results
  end

  private

    def load_active_poll
      @active_poll = ActivePoll.first
    end

end
