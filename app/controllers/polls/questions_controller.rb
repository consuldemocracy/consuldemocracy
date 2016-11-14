class Polls::QuestionsController < ApplicationController

  load_and_authorize_resource :poll
  load_and_authorize_resource :question, class: 'Poll::Question', through: :poll

  def answer
    partial_result = @question.partial_results.find_or_initialize_by(author: current_user,
                                                                     amount: 1,
                                                                     origin: 'web')

    partial_result.answer = params[:answer]
    partial_result.save!

    @answers_by_question_id = {@question.id => params[:answer]}
  end

end
