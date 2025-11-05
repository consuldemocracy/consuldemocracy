# app/controllers/comments/votes_controller.rb
class Comments::VotesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_comment
  load_and_authorize_resource through: :comment, through_association: :votes_for, only: [:destroy, :update]

  # POST /comments/:comment_id/votes
  def create
    authorize! :create, Vote.new(voter: current_user, votable: @comment)

    # --- THIS IS THE FINAL FIX ---
    #
    # We read the `params[:value]` from the URL (sent by our smart component)
    # and use the standard `acts_as_votable` methods.
    #
    if params[:value] == "yes"
      @comment.vote_up(current_user)
    elsif params[:value] == "no"
      @comment.vote_down(current_user)
    end
    # --- END OF FINAL FIX ---

    respond_to { |format| format.js { render :show } }
  end

  # PATCH /comments/:comment_id/votes/:id
  # This action is correct and uses the new `vote_params` logic
  def update
    @vote.update(vote_params)
    respond_to { |format| format.js { render :show } }
  end

  # DELETE /comments/:comment_id/votes/:id
  # This action is correct
  def destroy
    @vote.destroy
    respond_to { |format| format.js { render :show } }
  end

  private

  def load_comment
    @comment = Comment.find(params[:comment_id])
  end

  # This is needed by the `update` action
  def vote_params
    params.require(:vote).permit(:vote_weight, :vote_flag)
  end
end
