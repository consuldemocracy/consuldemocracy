class PollsController < ApplicationController
  include PollsHelper

  before_action :load_poll, except: [:index]
  before_action :load_active_poll, only: :index

  load_and_authorize_resource

  has_filters %w[current expired]
  has_orders %w[most_voted newest oldest], only: :show

  ::Poll::Answer # trigger autoload

  def index
    @polls = Kaminari.paginate_array(
      @polls.public_polls.not_budget.send(@current_filter).includes(:geozones).sort_for_list
    ).page(params[:page])
  end

  def show
    @questions = @poll.questions.for_render.sort_for_list
    @token = poll_voter_token(@poll, current_user)
    @poll_questions_answers = Poll::Question::Answer.visibles
                                                    .where(question: @poll.questions)
                                                    .where.not(description: "").order(:given_order)

    @answers_by_question_id = {}
    poll_answers = ::Poll::Answer.by_question(@poll.question_ids).by_author(current_user.try(:id))

    @last_pair_question_answers = {}
    @questions.each do |question|
      @answers_by_question_id[question.id] = question.answers.by_author(current_user).pluck(:answer)

      if question.enum_type&.include?("answer_couples")
        last_pair = question.pair_answers.by_author(current_user).first
        last_pair ||= generate_and_store_new_pair(question)
        @last_pair_question_answers[question.id] = last_pair
      end

      if question.enum_type&.include?("answer_set_closed") ||
        question.enum_type&.include?("answer_set_open")
        votation_answer_sets(question)
      end
    end

    @commentable = @poll
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
  end

  def stats
    @stats = Poll::Stats.new(@poll)
  end

  def results
  end

  private

    def votation_answer_sets(question)
      if question.votation_type.votation_set_answers.by_author(current_user).empty?
        question.question_answers&.sample(question.max_groups_answers).each do |question_answer|
          answer = VotationSetAnswer.new(answer: question_answer.title,
                                           votation_type: question.votation_type,
                                           author: current_user)
          question.votation_type.votation_set_answers << answer
        end
        !question.save
      end
    end

    def load_poll
      @poll = Poll.where(slug: params[:id]).first || Poll.where(id: params[:id]).first
    end

    def load_active_poll
      @active_poll = ActivePoll.first
    end

    def generate_and_store_new_pair(question)
      Poll::PairAnswer.generate_pair(question, current_user)
    end

end
