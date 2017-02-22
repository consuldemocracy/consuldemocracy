class PollsController < ApplicationController

  load_and_authorize_resource

  has_filters %w{current expired incoming}

  ::Poll::Answer # trigger autoload

  def index
    @polls = @polls.send(@current_filter).includes(:geozones).sort_for_list.page(params[:page])
  end

  def show
    @questions = @poll.questions.for_render.sort_for_list

    @answers_by_question_id = {}
    poll_answers = ::Poll::Answer.by_question(@poll.question_ids).by_author(current_user.try(:id))
    poll_answers.each do |answer|
      @answers_by_question_id[answer.question_id] = answer.answer
    end
  end

  def results_2017
    @poll_1 = ::Poll.where("name ILIKE ?", "%Billete único%").first
    @poll_2 = ::Poll.where("name ILIKE ?", "%Gran Vía%").first
    @poll_3 = ::Poll.where("name ILIKE ?", "%Territorial de Barajas%").first
    @poll_4 = ::Poll.where("name ILIKE ?", "%Territorial de San Blas%").first
    @poll_5 = ::Poll.where("name ILIKE ?", "%Hortaleza%").first
    @poll_6 = ::Poll.where("name ILIKE ?", "%culturales en Retiro%").first
    @poll_7 = ::Poll.where("name ILIKE ?", "%Distrito de Salamanca%").first
    @poll_8 = ::Poll.where("name ILIKE ?", "%Distrito de Vicálvaro%").first
  end

  def stats_2017
    @participantes_totales = ::Poll::Voter.select(:user_id).distinct.count
    @votos_totales = ::Poll::Voter.count

    @votos_total_web = ::Poll::Voter.web.count
    @votos_total_booth = ::Poll::Voter.booth.count
    @votos_total_letter = ::Poll::Voter.letter.count

    @participantes_total_web = ::Poll::Voter.web.select(:user_id).distinct.count
    @participantes_total_booth = ::Poll::Voter.booth.select(:user_id).distinct.count
    @participantes_total_letter = ::Poll::Voter.letter.select(:user_id).distinct.count
  end
end
