# app/controllers/comments/votes_controller.rb
class Comments::VotesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_comment
  load_and_authorize_resource through: :comment, through_association: :votes_for, only: [:destroy, :update]

  # POST /comments/:comment_id/votes
  def create
    authorize! :create, Vote.new(voter: current_user, votable: @comment)

    # This expects `vote_params` from the button, not `params[:value]`.
    @comment.vote_by(
      voter: current_user,
      vote_weight: vote_params[:vote_weight],
      vote_flag: vote_params[:vote_flag]
    )

    respond_to { |format| format.js { render :show } }
  end

  # PATCH /comments/:comment_id/votes/:id
  def update
    @vote.update(vote_params)
    respond_to { |format| format.js { render :show } }
  end

  # DELETE /comments/:comment_id/votes/:id
  def destroy
    @vote.destroy
    respond_to { |format| format.js { render :show } }
  end

  private

  def load_comment
    @comment = Comment.find(params[:comment_id])
  end

  def vote_params
    params.require(:vote).permit(:vote_weight, :vote_flag)
  end
end