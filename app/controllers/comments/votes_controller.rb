# app/controllers/comments/votes_controller.rb
class Comments::VotesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_comment
  load_and_authorize_resource through: :comment, through_association: :votes_for, only: [:destroy, :update]

  def create
    authorize! :create, Vote.new(voter: current_user, votable: @comment)

    @comment.vote_by(
      voter: current_user,
      vote_weight: vote_params[:vote_weight],
      vote_flag: vote_params[:vote_flag]
    )
    respond_to do |format|
      format.html { redirect_to request.referer || @comment, notice: I18n.t("flash.actions.create.vote") }
      format.js { render :show }
    end
  end

  def update
    @vote.update(vote_params)
    respond_to do |format|
      format.html { redirect_to request.referer || @comment, notice: I18n.t("flash.actions.update.vote") }
      format.js { render :show }
    end
  end

  def destroy
    @vote.destroy
    respond_to do |format|
      format.html { redirect_to request.referer || @comment, notice: I18n.t("flash.actions.destroy.vote") }
      format.js { render :show }
    end
  end

  private

  def load_comment
    @comment = Comment.find(params[:comment_id])
  end

  def vote_params
    params.require(:vote).permit(:vote_weight, :vote_flag)
  end
end