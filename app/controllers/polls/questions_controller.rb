class Polls::QuestionsController < ApplicationController

  load_and_authorize_resource :poll
  load_and_authorize_resource :question, class: 'Poll::Question'

  has_orders %w{most_voted newest oldest}, only: :show

  def show
    @commentable = @question.proposal.present? ? @question.proposal : @question
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
    set_comment_flags(@comment_tree.comments)

    question_answer = @question.answers.where(author_id: current_user.try(:id)).first
    @answers_by_question_id = {@question.id => question_answer.try(:answer)}
  end

  def answer
    answer = @question.answers.find_or_initialize_by(author: current_user)

    answer.answer = params[:answer]
    answer.save!
    answer.record_voter_participation

    @answers_by_question_id = {@question.id => params[:answer]}
  end

end
