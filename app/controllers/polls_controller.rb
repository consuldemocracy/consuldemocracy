class PollsController < ApplicationController

  load_and_authorize_resource

  has_filters %w{current expired incoming}

  def index
    @polls = @polls.send(@current_filter).sort_for_list.page(params[:page])
  end

  def show
    @answerable_questions     = @poll.questions.answerable_by(current_user).for_render.sort_for_list
    @non_answerable_questions = @poll.questions.where.not(id: @answerable_questions.map(&:id)).for_render.sort_for_list

    @answers_by_question_id = {}
    poll_partial_results = Poll::PartialResult.by_question(@poll.question_ids).by_author(current_user.try(:id))
    poll_partial_results.each do |result|
      @answers_by_question_id[result.question_id] = result.answer
    end
  end

end
