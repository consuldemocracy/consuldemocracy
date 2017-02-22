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
  end

  def stats_2017
  end
end
