class Legislation::QuestionsController < Legislation::BaseController
  load_and_authorize_resource :process
  load_and_authorize_resource :question, through: :process

  has_orders %w[most_voted newest oldest], only: :show

  def show
    @commentable = @question
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
    set_comment_flags(@comment_tree.comments)
    @answer = @question.answer_for_user(current_user) || Legislation::Answer.new
  end
end
