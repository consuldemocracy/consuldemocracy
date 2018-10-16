class PollsController < ApplicationController
  include PollsHelper

  load_and_authorize_resource

  has_filters %w{current expired incoming}
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
    @votacion = Poll.kind_of_cartel.last
    @stats = calcula_resultados_cartel(@votacion)
    @all_ages_count = @stats[:age_groups].values.sum.to_f
  end

  def results
    @votacion = Poll.kind_of_cartel.last
    @answers = @votacion.questions.first.answers.to_a
    @results = []
    @votacion.questions.first.question_answers.each do |question_answer|
      votos = question_answer.total_votes
      porcentaje = votos * 100.0 / @answers.size
       @results << {
        respuesta: question_answer,
        votos: votos,
        porcentaje: porcentaje
        }
    end
    @results = @results.sort { |a, b| b[:votos] <=> a[:votos] }
  end
end
