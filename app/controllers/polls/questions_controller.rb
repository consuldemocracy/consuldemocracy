class Polls::QuestionsController < ApplicationController
  load_and_authorize_resource :poll
  load_and_authorize_resource :question, class: "Poll::Question"

  before_action :load_page
  before_action :load_answers, only: :answers

  has_orders %w[most_voted newest oldest], only: :show

  def answer
    if @question.votation_type.nil?
      answer = @question.answers.find_or_initialize_by(author: current_user)
    else
      answer = @question.votation_type.answer(current_user, params[:answer])
    end
    save_answer(answer, params[:answer], params[:token]) if answer.present?

    load_answers
    render :answers
  end

  def prioritized_answers
    if params[:ordered_list].present?
      params[:ordered_list].each_with_index do |answer_title, i|
        answer = @question.votation_type.answer(current_user, answer_title, order: i + 1)
        save_answer(answer, answer_title, params[:token]) if answer.present?
      end
    end

    load_answers
    render :answers
  end

  private

    def load_page
      @page = params[:page].presence || 1
    end

    def load_answers
      @answers = @question.question_answers
      @answers_by_question_id = {
        @question.id => @question.answers.by_author(current_user).order(:order).pluck(:answer)
      }
    end

    def save_answer(answer, answer_title, token)
      answer.answer = answer_title
      answer.save! if answer.persisted?
      answer.save_and_record_voter_participation(token)
      update_answer_values
    end

    def update_answer_values
      if @question.votation_type&.prioritized?
        @question.votation_type.update_priorized_values(current_user.id)
      end
      @question.question_answers.each(&:set_most_voted)
    end
end
