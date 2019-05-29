class Polls::QuestionsController < ApplicationController

  load_and_authorize_resource :poll
  load_and_authorize_resource :question, class: "Poll::Question"

  has_orders %w[most_voted newest oldest], only: :show

  def answer
    answer = store_answer
    vote_stored(answer, params[:answer], params[:token]) if answer.present?
    load_for_answers
    if @question.enum_type&.include?("answer_couples")
      last_pair ||= generate_and_store_new_pair(@question)
      @last_pair_question_answers = {@question.id => last_pair}
    end
  end

  def load_answers
    load_for_answers
    render action: "answer.js.erb"
  end

  def prioritized_answers
    unless params[:ordered_list].empty?
      params[:ordered_list].each_with_index do |answer, i|
        answer_obj = @question.votation_type.answer(current_user,
                                       answer,
                                       order: i + 1)
        vote_stored(answer_obj, answer, params[:tooken]) if answer_obj.present?
      end
      @question.votation_type.update_priorized_values(current_user.id)
    end
    load_for_answers
    render action: "answer.js.erb"
  end

  private

    def load_for_answers
      @page = params[:page].present? ? params[:page] : 1
      question_answers
      @answers_by_question_id = {@question.id => @question.answers
                                                   .by_author(current_user)
                                                   .order(:order)
                                                   .pluck(:answer)}
    end

    def vote_stored(answer, new_answer, token)
      answer.answer = new_answer
      answer.touch if answer.persisted?
      answer.save!
      answer.record_voter_participation(token)
      @question.question_answers.visibles.where(question_id: @question).each do |question_answer|
        question_answer.set_most_voted
      end
    end

    def store_answer
      if @question.votation_type.nil?
        answer = @question.answers.find_or_initialize_by(author: current_user)
      else
        answer = @question.votation_type.answer(current_user,
                                                params[:answer],
                                                positive: params[:positive])
      end
      answer
    end

    def generate_and_store_new_pair(question)
      Poll::PairAnswer.generate_pair(question, current_user)
    end

    def question_answers
      if @question.is_positive_negative?
        @answers = @question.question_answers.visibles.page(@page)
      else
        @answers = @question.question_answers.visibles
      end
    end

end
