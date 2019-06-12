class Polls::AnswersController < ApplicationController

  load_and_authorize_resource :poll
  load_and_authorize_resource :question, class: "Poll::Question"
  authorize_resource :answer, class: "Poll::Answer"

  def create
    @question = Poll::Question.find_by(id: params[:id])
    if @question.votation_type.open? && !check_question_answer_exist
      @question.question_answers.create(
        title: params[:answer],
        given_order: @question.question_answers.count + 1,
        hidden: false
      )
      flash.now[:notice] = t("dashboard.polls.index.succesfull")
    else
      flash.now[:alert] = "Unfortunately failed to sent"
    end
    load_for_answers
    if @question.enum_type&.include?("answer_couples")
      last_pair ||= generate_and_store_new_pair(@question)
      @last_pair_question_answers = {@question.id => last_pair}
    end
    render "polls/questions/answer", format: :js
  end

  def delete
    @question = Poll::Question.find_by(id: params[:id])
    !@question.answers.find_by(author: current_user, answer: params[:answer]).destroy
    @question.question_answers.each do |question_answer|
      question_answer.set_most_voted
    end
    question_answers
    load_for_answers
    if @question.enum_type&.include?("answer_couples")
      last_pair ||= generate_and_store_new_pair(@question)
      @last_pair_question_answers = {@question.id => last_pair}
    end
    render "polls/questions/answer", format: :js
  end

  private

    def check_question_answer_exist
      exist = false
      @question.question_answers.each do |question_answer|
        break if exist
        exist = true if question_answer.title == params[:answer]
      end
      exist
    end

    def load_for_answers
      @page = params[:page].present? ? params[:page] : 1
      question_answers
      @answers_by_question_id = {@question.id => @question.answers
                                                   .by_author(current_user)
                                                   .order(:order)
                                                   .pluck(:answer)}
    end

    def question_answers
      if @question.is_positive_negative?
        @answers = @question.question_answers.visibles.page(params[:page])
      else
        @answers = @question.question_answers.visibles
      end
    end

end
