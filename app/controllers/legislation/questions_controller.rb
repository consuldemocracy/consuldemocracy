class Legislation::QuestionsController < Legislation::BaseController
  load_and_authorize_resource :process
  load_and_authorize_resource :question, through: :process

  has_orders %w[most_voted newest oldest], only: :show

  def show
    @comment_tree = CommentTree.new(@question, params[:page], @current_order)
    @answer = @question.answer_for_user(current_user) || Legislation::Answer.new
  end
end
