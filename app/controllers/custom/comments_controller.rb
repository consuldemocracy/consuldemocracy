require_dependency Rails.root.join('app', 'controllers', 'comments_controller').to_s

class CommentsController < ApplicationController

  def vote
    @comment.register_vote(current_user, params[:value])
    respond_with @comment
  end

end
