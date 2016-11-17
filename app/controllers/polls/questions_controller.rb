class Polls::QuestionsController < ApplicationController

  load_and_authorize_resource :poll
  load_and_authorize_resource :question, class: 'Poll::Question'#, through: :poll

  has_filters %w{opened expired incoming}
  has_orders %w{most_voted newest oldest}, only: :show

  def show
    @commentable = @question.proposal.present? ? @question.proposal : @question
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
    set_comment_flags(@comment_tree.comments)

    #@question_answer = @question.answers.where(author_id: current_user.try(:id)).first
    @answers_by_question_id = {@question.id => params[:answer]}
  end

  def answer
    partial_result = @question.partial_results.find_or_initialize_by(author: current_user,
                                                                     amount: 1,
                                                                     origin: 'web')

    partial_result.answer = params[:answer]
    partial_result.save!

    @answers_by_question_id = {@question.id => params[:answer]}
  end

end
